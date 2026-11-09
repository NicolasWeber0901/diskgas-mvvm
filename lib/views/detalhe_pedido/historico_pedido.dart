import 'package:flutter/material.dart';

import '../../models/pedido.dart';
import '../../models/situacao_pedido.dart';
import '../tema.dart';
import '../widgets/formatos.dart';

class _Etapa {
  final IconData icone;
  final Color cor;
  final String titulo;
  final String? detalhe;

  const _Etapa(this.icone, this.cor, this.titulo, this.detalhe);
}

class HistoricoPedido extends StatelessWidget {
  final Pedido pedido;

  const HistoricoPedido(this.pedido, {super.key});

  List<_Etapa> get _etapas {
    final situacao = pedido.situacao;
    final tempo = pedido.tempoEstimadoMinutos;
    final entrega = pedido.dataEntrega;
    return [
      _Etapa(
        Icons.receipt_long_outlined,
        CoresDiskGas.ambar,
        'Pedido feito',
        formatarData(pedido.dataCriacao),
      ),
      if (situacao == SituacaoPedido.aceito ||
          situacao == SituacaoPedido.entregue)
        _Etapa(
          Icons.local_shipping_outlined,
          CoresDiskGas.azulEscuro,
          'Aceito',
          situacao == SituacaoPedido.aceito || tempo == null
              ? null
              : 'Tempo estimado: $tempo min',
        ),
      if (situacao == SituacaoPedido.entregue)
        _Etapa(
          Icons.check_circle_outline,
          CoresDiskGas.verde,
          'Entregue',
          entrega == null ? null : formatarData(entrega),
        ),
      if (situacao == SituacaoPedido.recusado)
        _Etapa(
          Icons.cancel_outlined,
          CoresDiskGas.vermelho,
          'Recusado',
          pedido.motivoRecusa,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final etapas = _etapas;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Histórico', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final etapa in etapas)
              _LinhaEtapa(etapa, ultima: etapa == etapas.last),
          ],
        ),
      ),
    );
  }
}

class _LinhaEtapa extends StatelessWidget {
  final _Etapa etapa;
  final bool ultima;

  const _LinhaEtapa(this.etapa, {required this.ultima});

  @override
  Widget build(BuildContext context) {
    final detalhe = etapa.detalhe;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: etapa.cor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(etapa.icone, size: 20, color: etapa.cor),
              ),
              if (!ultima)
                Expanded(child: Container(width: 2, color: CoresDiskGas.areia)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 6, bottom: ultima ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    etapa.titulo,
                    style: TextStyle(
                      color: etapa.cor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (detalhe != null)
                    Text(
                      detalhe,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
