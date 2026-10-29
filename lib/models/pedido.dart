import 'package:cloud_firestore/cloud_firestore.dart';

import 'deslocamento.dart';
import 'endereco.dart';
import 'item_pedido.dart';
import 'situacao_pedido.dart';

class Pedido {
  final String id;
  final String clienteId;
  final String clienteNome;
  final String clienteTelefone;
  final Endereco endereco;
  final List<ItemPedido> itens;
  final SituacaoPedido situacao;
  final DateTime dataCriacao;
  final Deslocamento? deslocamento;
  final int? tempoEstimadoMinutos;
  final String? motivoRecusa;
  final DateTime? dataEntrega;

  const Pedido({
    required this.id,
    required this.clienteId,
    required this.clienteNome,
    required this.clienteTelefone,
    required this.endereco,
    required this.itens,
    required this.situacao,
    required this.dataCriacao,
    this.deslocamento,
    this.tempoEstimadoMinutos,
    this.motivoRecusa,
    this.dataEntrega,
  });

  double get valorTotal =>
      itens.fold(0, (total, item) => total + item.subtotal);

  factory Pedido.fromMap(String id, Map<String, dynamic> map) {
    final distancia = map['distanciaMetros'] as num?;
    final duracao = map['duracaoSegundos'] as num?;
    return Pedido(
      id: id,
      clienteId: map['clienteId'] as String? ?? '',
      clienteNome: map['clienteNome'] as String? ?? '',
      clienteTelefone: map['clienteTelefone'] as String? ?? '',
      endereco: Endereco.fromMap(
        Map<String, dynamic>.from(map['endereco'] as Map? ?? {}),
      ),
      itens: (map['itens'] as List? ?? [])
          .map((item) => ItemPedido.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      situacao: SituacaoPedido.values.byName(
        map['situacao'] as String? ?? 'aguardando',
      ),
      dataCriacao: _data(map['dataCriacao']) ?? DateTime.now(),
      deslocamento: distancia != null && duracao != null
          ? Deslocamento(
              distanciaMetros: distancia.toInt(),
              duracaoSegundos: duracao.toInt(),
            )
          : null,
      tempoEstimadoMinutos: (map['tempoEstimadoMinutos'] as num?)?.toInt(),
      motivoRecusa: map['motivoRecusa'] as String?,
      dataEntrega: _data(map['dataEntrega']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'clienteNome': clienteNome,
      'clienteTelefone': clienteTelefone,
      'endereco': endereco.toMap(),
      'itens': itens.map((item) => item.toMap()).toList(),
      'situacao': situacao.name,
      'dataCriacao': Timestamp.fromDate(dataCriacao),
      if (deslocamento != null) ...{
        'distanciaMetros': deslocamento!.distanciaMetros,
        'duracaoSegundos': deslocamento!.duracaoSegundos,
      },
      if (tempoEstimadoMinutos != null)
        'tempoEstimadoMinutos': tempoEstimadoMinutos,
      if (motivoRecusa != null) 'motivoRecusa': motivoRecusa,
      if (dataEntrega != null) 'dataEntrega': Timestamp.fromDate(dataEntrega!),
    };
  }

  static DateTime? _data(Object? valor) {
    if (valor is Timestamp) return valor.toDate();
    return null;
  }
}
