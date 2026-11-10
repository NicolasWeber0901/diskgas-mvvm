import 'package:cloud_firestore/cloud_firestore.dart';

import 'tipo_movimentacao.dart';

class MovimentacaoEstoque {
  final String id;
  final String produtoId;
  final String nomeProduto;
  final TipoMovimentacao tipo;
  final int quantidade;
  final int saldo;
  final DateTime data;
  final String usuarioId;
  final String? pedidoId;
  final String? clienteNome;

  const MovimentacaoEstoque({
    required this.id,
    required this.produtoId,
    required this.nomeProduto,
    required this.tipo,
    required this.quantidade,
    required this.saldo,
    required this.data,
    required this.usuarioId,
    this.pedidoId,
    this.clienteNome,
  });

  factory MovimentacaoEstoque.fromMap(String id, Map<String, dynamic> map) {
    final data = map['data'];
    return MovimentacaoEstoque(
      id: id,
      produtoId: map['produtoId'] as String? ?? '',
      nomeProduto: map['nomeProduto'] as String? ?? '',
      tipo: TipoMovimentacao.values.firstWhere(
        (tipo) => tipo.name == map['tipo'],
        orElse: () => TipoMovimentacao.entrada,
      ),
      quantidade: (map['quantidade'] as num? ?? 0).toInt(),
      saldo: (map['saldo'] as num? ?? 0).toInt(),
      data: data is Timestamp ? data.toDate() : DateTime.now(),
      usuarioId: map['usuarioId'] as String? ?? '',
      pedidoId: map['pedidoId'] as String?,
      clienteNome: map['clienteNome'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'produtoId': produtoId,
      'nomeProduto': nomeProduto,
      'tipo': tipo.name,
      'quantidade': quantidade,
      'saldo': saldo,
      'data': Timestamp.fromDate(data),
      'usuarioId': usuarioId,
      if (pedidoId != null) 'pedidoId': pedidoId,
      if (clienteNome != null) 'clienteNome': clienteNome,
    };
  }
}
