import 'package:flutter/material.dart';

import '../../models/deslocamento.dart';
import '../../models/pedido.dart';
import '../../viewmodels/detalhe_pedido_viewmodel.dart';
import '../tema.dart';
import '../widgets/mensagem_erro.dart';
import 'mapa_rota.dart';

class BlocoRota extends StatelessWidget {
  final DetalhePedidoViewModel viewModel;
  final Pedido pedido;

  const BlocoRota({required this.viewModel, required this.pedido, super.key});

  @override
  Widget build(BuildContext context) {
    final deslocamento = pedido.deslocamento;
    if (viewModel.calculandoRota) {
      return const Row(
        children: [
          SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('Calculando a distância...'),
        ],
      );
    }
    if (deslocamento == null) return MensagemErro(viewModel.avisoRota);
    final rota = viewModel.rota;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (rota.isNotEmpty)
            MapaRota(rota: rota, cliente: pedido.clienteNome),
          _ResumoRota(deslocamento),
        ],
      ),
    );
  }
}

class _ResumoRota extends StatelessWidget {
  final Deslocamento deslocamento;

  const _ResumoRota(this.deslocamento);

  @override
  Widget build(BuildContext context) {
    final km = deslocamento.distanciaKm.toStringAsFixed(1).replaceAll('.', ',');
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: CoresDiskGas.azulAgua.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.route_rounded,
              color: CoresDiskGas.azulEscuro,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: _ValorRota('Distância', '$km km')),
          Expanded(
            child: _ValorRota(
              'Deslocamento',
              '${deslocamento.duracaoMinutos} min',
            ),
          ),
        ],
      ),
    );
  }
}

class _ValorRota extends StatelessWidget {
  final String rotulo;
  final String valor;

  const _ValorRota(this.rotulo, this.valor);

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rotulo,
          style: textos.bodySmall?.copyWith(color: CoresDiskGas.cinzaQuente),
        ),
        Text(valor, style: textos.titleLarge),
      ],
    );
  }
}
