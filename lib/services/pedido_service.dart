import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/pedido.dart';
import 'falhas.dart';

/// US06: grava os pedidos em pedidos/{id}.
class PedidoService {
  final FirebaseFirestore _firestore;

  PedidoService(this._firestore);

  CollectionReference<Map<String, dynamic>> get _pedidos =>
      _firestore.collection('pedidos');

  Future<String> criar(Pedido pedido) async {
    try {
      final documento = await _pedidos.add(pedido.toMap());
      return documento.id;
    } on FirebaseException {
      throw const FalhaConexao();
    }
  }
}
