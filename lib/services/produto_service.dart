import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/produto.dart';
import 'falhas.dart';

/// US05 e US06: produtos e quantidades em estoque, em produtos/{id}.
class ProdutoService {
  final FirebaseFirestore _firestore;

  ProdutoService(this._firestore);

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
}
