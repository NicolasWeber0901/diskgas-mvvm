import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/deslocamento.dart';
import '../models/item_pedido.dart';
import '../models/pedido.dart';
import 'falhas.dart';

/// US06, US07, US10 a US15: grava e acompanha os pedidos em pedidos/{id}.
class PedidoService {
  final FirebaseFirestore _firestore;

  PedidoService(this._firestore);

  CollectionReference<Map<String, dynamic>> get _pedidos =>
      _firestore.collection('pedidos');

  CollectionReference<Map<String, dynamic>> get _produtos =>
      _firestore.collection('produtos');

  Future<String> criar(Pedido pedido) async {
    try {
      final documento = await _pedidos.add({
        ...pedido.toMap(),
        'dataCriacao': FieldValue.serverTimestamp(),
      });
      return documento.id;
    } on FirebaseException {
      throw const FalhaConexao();
    }
  }

  Stream<List<Pedido>> observarPedidosDoCliente(String clienteId) {
    return _pedidos
        .where('clienteId', isEqualTo: clienteId)
        .snapshots()
        .map(
          (consulta) => consulta.docs
              .map(
                (documento) => Pedido.fromMap(documento.id, documento.data()),
              )
              .toList(),
        );
  }

  Stream<List<Pedido>> observarTodos() {
    return _pedidos.snapshots().map(
      (consulta) => consulta.docs
          .map((documento) => Pedido.fromMap(documento.id, documento.data()))
          .toList(),
    );
  }

  Stream<Pedido?> observarPedido(String id) {
    return _pedidos
        .doc(id)
        .snapshots()
        .map(
          (documento) => documento.exists
              ? Pedido.fromMap(documento.id, documento.data()!)
              : null,
        );
  }

  Future<void> gravarDeslocamento(String id, Deslocamento deslocamento) {
    return _atualizar(id, {
      'distanciaMetros': deslocamento.distanciaMetros,
      'duracaoSegundos': deslocamento.duracaoSegundos,
    });
  }

  Future<void> aceitar(String id, int tempoEstimadoMinutos) {
    return _atualizar(id, {
      'situacao': 'aceito',
      'tempoEstimadoMinutos': tempoEstimadoMinutos,
    });
  }

  Future<void> ampliarTempo(String id, int minutos) {
    return _atualizar(id, {
      'tempoEstimadoMinutos': FieldValue.increment(minutos),
    });
  }

  Future<void> recusar(String id, String motivo) {
    return _atualizar(id, {'situacao': 'recusado', 'motivoRecusa': motivo});
  }

  Future<void> finalizarEntrega(
    Pedido pedido,
    Map<String, int> quantidadesEntregues,
  ) async {
    try {
      await _firestore.runTransaction((transacao) async {
        final documentoPedido = _pedidos.doc(pedido.id);
        final atual = await transacao.get(documentoPedido);
        if (atual.data()?['situacao'] != 'aceito') {
          throw const FalhaServico('Este pedido não pode mais ser finalizado.');
        }

        final estoques = <String, int>{};
        for (final item in pedido.itens) {
          final produto = await transacao.get(_produtos.doc(item.produtoId));
          if (!produto.exists) {
            throw FalhaServico(
              'O produto ${item.nomeProduto} não existe mais.',
            );
          }
          final estoque = (produto.data()?['quantidadeEstoque'] as num? ?? 0)
              .toInt();
          final entregue =
              quantidadesEntregues[item.produtoId] ?? item.quantidadePedida;
          if (estoque < entregue) throw EstoqueInsuficiente(item.nomeProduto);
          estoques[item.produtoId] = estoque;
        }

        final itensEntregues = <ItemPedido>[];
        for (final item in pedido.itens) {
          final entregue =
              quantidadesEntregues[item.produtoId] ?? item.quantidadePedida;
          transacao.update(_produtos.doc(item.produtoId), {
            'quantidadeEstoque': estoques[item.produtoId]! - entregue,
          });
          itensEntregues.add(
            ItemPedido(
              produtoId: item.produtoId,
              nomeProduto: item.nomeProduto,
              precoUnitario: item.precoUnitario,
              quantidadePedida: item.quantidadePedida,
              quantidadeEntregue: entregue,
            ),
          );
        }
        transacao.update(documentoPedido, {
          'situacao': 'entregue',
          'itens': itensEntregues.map((item) => item.toMap()).toList(),
          'dataEntrega': Timestamp.now(),
        });
      });
    } on FalhaServico {
      rethrow;
    } on FirebaseException {
      throw const FalhaConexao();
    }
  }

  Future<void> _atualizar(String id, Map<String, Object?> dados) async {
    try {
      await _pedidos.doc(id).update(dados);
    } on FirebaseException {
      throw const FalhaConexao();
    }
  }
}
