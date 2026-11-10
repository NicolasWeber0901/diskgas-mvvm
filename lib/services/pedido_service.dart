import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/deslocamento.dart';
import '../models/item_pedido.dart';
import '../models/movimentacao_estoque.dart';
import '../models/pedido.dart';
import '../models/tipo_movimentacao.dart';
import 'falhas.dart';

/// US06, US07, US10 a US15: grava e acompanha os pedidos em pedidos/{id}.
class PedidoService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PedidoService(this._firestore, this._auth);

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
      if (deslocamento.polilinha != null) 'polilinha': deslocamento.polilinha,
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
          final saldo = estoques[item.produtoId]! - entregue;
          transacao.update(_produtos.doc(item.produtoId), {
            'quantidadeEstoque': saldo,
          });
          if (entregue > 0) {
            transacao.set(
              _firestore.collection('movimentacoes_estoque').doc(),
              {
                ...MovimentacaoEstoque(
                  id: '',
                  produtoId: item.produtoId,
                  nomeProduto: item.nomeProduto,
                  tipo: TipoMovimentacao.saida,
                  quantidade: entregue,
                  saldo: saldo,
                  data: DateTime.now(),
                  usuarioId: _auth.currentUser?.uid ?? '',
                  pedidoId: pedido.id,
                  clienteNome: pedido.clienteNome,
                ).toMap(),
                'data': FieldValue.serverTimestamp(),
              },
            );
          }
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
