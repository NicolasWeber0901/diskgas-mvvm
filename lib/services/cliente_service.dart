import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cliente.dart';
import 'falhas.dart';

/// US04 e US16: clientes em usuarios/{uid} e CPFs já usados em cpfs/{cpf}.
class ClienteService {
  final FirebaseFirestore _firestore;

  ClienteService(this._firestore);

  Future<Cliente?> buscar(String uid) async {
    try {
      final documento = await _firestore.collection('usuarios').doc(uid).get();
      final dados = documento.data();
      if (dados == null || dados['perfil'] != 'cliente') return null;
      return Cliente.fromMap(documento.id, dados);
    } on FirebaseException {
      throw const FalhaConexao();
    }
  }

  Stream<List<Cliente>> observarClientes() {
    return _firestore
        .collection('usuarios')
        .where('perfil', isEqualTo: 'cliente')
        .snapshots()
        .map(
          (consulta) => consulta.docs
              .map(
                (documento) => Cliente.fromMap(documento.id, documento.data()),
              )
              .toList(),
        );
  }

  Future<bool> cpfJaCadastrado(String cpf) async {
    try {
      final documento = await _firestore.collection('cpfs').doc(cpf).get();
      return documento.exists;
    } on FirebaseException {
      throw const FalhaConexao();
    }
  }

  Future<void> salvar(Cliente cliente) async {
    try {
      final lote = _firestore.batch();
      lote.set(
        _firestore.collection('usuarios').doc(cliente.id),
        cliente.toMap(),
      );
      lote.set(_firestore.collection('cpfs').doc(cliente.cpf), {
        'uid': cliente.id,
      });
      await lote.commit();
    } on FirebaseException {
      throw const FalhaConexao();
    }
  }
}
