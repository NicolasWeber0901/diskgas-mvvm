import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/movimentacao_estoque.dart';
import '../models/produto.dart';
import '../models/tipo_movimentacao.dart';
import 'falhas.dart';

/// US05, US06, US08 (produtos fixos), US09 e US18: produtos e estoque.
class ProdutoService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProdutoService(this._firestore, this._auth);

  static const produtosFixos = [
    Produto(id: 'gas', nome: 'Gás P13', preco: 120, quantidadeEstoque: 0),
    Produto(
      id: 'agua',
      nome: 'Água mineral 20 L',
      preco: 15,
      quantidadeEstoque: 0,
    ),
  ];

  CollectionReference<Map<String, dynamic>> get _produtos =>
      _firestore.collection('produtos');

  CollectionReference<Map<String, dynamic>> get _movimentacoes =>
      _firestore.collection('movimentacoes_estoque');

  Stream<List<Produto>> observarProdutos() {
    return _produtos
        .orderBy('nome')
        .snapshots()
        .map(
          (consulta) => consulta.docs
              .map(
                (documento) => Produto.fromMap(documento.id, documento.data()),
              )
              .toList(),
        );
  }

  Future<void> garantirProdutosFixos() async {
    try {
      await _firestore.runTransaction((transacao) async {
        final faltando = <Produto>[];
        for (final produto in produtosFixos) {
          final documento = await transacao.get(_produtos.doc(produto.id));
          if (!documento.exists) faltando.add(produto);
        }
        for (final produto in faltando) {
          transacao.set(_produtos.doc(produto.id), produto.toMap());
        }
      });
    } on FirebaseException {
      throw const FalhaConexao();
    }
  }

  Future<List<Produto>> buscarProdutos() async {
    try {
      final consulta = await _produtos.get();
      return consulta.docs
          .map((documento) => Produto.fromMap(documento.id, documento.data()))
          .toList();
    } on FirebaseException {
      throw const FalhaConexao();
    }
  }

  Future<void> criar(Produto produto) async {
    try {
      final documento = _produtos.doc();
      final lote = _firestore.batch();
      lote.set(documento, produto.toMap());
      if (produto.quantidadeEstoque > 0) {
        lote.set(
          _movimentacoes.doc(),
          _movimentacao(
            produtoId: documento.id,
            nomeProduto: produto.nome,
            tipo: TipoMovimentacao.inicial,
            quantidade: produto.quantidadeEstoque,
            saldo: produto.quantidadeEstoque,
          ),
        );
      }
      await lote.commit();
    } on FirebaseException {
      throw const FalhaConexao();
    }
  }

  Future<void> editar(
    String id, {
    required String nome,
    required double preco,
  }) async {
    try {
      await _produtos.doc(id).update({'nome': nome, 'preco': preco});
    } on FirebaseException {
      throw const FalhaConexao();
    }
  }

  Future<void> registrarEntrada(String id, int quantidade) async {
    try {
      await _firestore.runTransaction((transacao) async {
        final documento = _produtos.doc(id);
        final atual = await transacao.get(documento);
        if (!atual.exists) throw const FalhaConexao();
        final dados = atual.data()!;
        final saldo =
            (dados['quantidadeEstoque'] as num? ?? 0).toInt() + quantidade;
        transacao.update(documento, {'quantidadeEstoque': saldo});
        transacao.set(
          _movimentacoes.doc(),
          _movimentacao(
            produtoId: id,
            nomeProduto: dados['nome'] as String? ?? '',
            tipo: TipoMovimentacao.entrada,
            quantidade: quantidade,
            saldo: saldo,
          ),
        );
      });
    } on FalhaServico {
      rethrow;
    } on FirebaseException {
      throw const FalhaConexao();
    }
  }

  Stream<List<MovimentacaoEstoque>> observarMovimentacoes() {
    return _movimentacoes
        .orderBy('data', descending: true)
        .snapshots()
        .map(
          (consulta) => consulta.docs
              .map(
                (documento) =>
                    MovimentacaoEstoque.fromMap(documento.id, documento.data()),
              )
              .toList(),
        );
  }

  Map<String, dynamic> _movimentacao({
    required String produtoId,
    required String nomeProduto,
    required TipoMovimentacao tipo,
    required int quantidade,
    required int saldo,
  }) {
    return {
      ...MovimentacaoEstoque(
        id: '',
        produtoId: produtoId,
        nomeProduto: nomeProduto,
        tipo: tipo,
        quantidade: quantidade,
        saldo: saldo,
        data: DateTime.now(),
        usuarioId: _auth.currentUser?.uid ?? '',
      ).toMap(),
      'data': FieldValue.serverTimestamp(),
    };
  }
}
