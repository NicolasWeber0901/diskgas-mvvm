import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/produto.dart';
import 'falhas.dart';

/// US05, US06, US08 (produtos fixos) e US09: produtos e estoque.
class ProdutoService {
  final FirebaseFirestore _firestore;

  ProdutoService(this._firestore);

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
      await _produtos.add(produto.toMap());
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
      await _produtos.doc(id).update({
        'quantidadeEstoque': FieldValue.increment(quantidade),
      });
    } on FirebaseException {
      throw const FalhaConexao();
    }
  }
}
