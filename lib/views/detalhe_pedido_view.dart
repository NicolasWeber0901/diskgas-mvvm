import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/pedido.dart';
import '../models/situacao_pedido.dart';
import '../viewmodels/detalhe_pedido_viewmodel.dart';
import 'detalhe_pedido/bloco_rota.dart';
import 'detalhe_pedido/cartao_cliente.dart';
import 'detalhe_pedido/dialogos_pedido.dart';
import 'detalhe_pedido/historico_pedido.dart';
import 'detalhe_pedido/itens_pedido.dart';
import 'tema.dart';
import 'widgets/abrir_dialogo.dart';
import 'widgets/aviso_destaque.dart';
import 'widgets/botao_sair.dart';
import 'widgets/mensagem_erro.dart';

/// Detalhe do pedido para o administrador (US10 a US15).
class DetalhePedidoView extends StatelessWidget {
  const DetalhePedidoView({super.key});

  Future<void> _abrirDialogo(
    BuildContext context,
    DetalhePedidoViewModel viewModel,
    Widget dialogo,
  ) async {
    viewModel.limparErro();
    await abrirDialogo<void, DetalhePedidoViewModel>(
      context,
      viewModel,
      dialogo,
    );
    viewModel.limparErro();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DetalhePedidoViewModel>();
    final pedido = viewModel.pedido;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/admin'),
        ),
        title: const Text('Pedido'),
        actions: const [BotaoSair()],
      ),
      body: viewModel.carregando
          ? const Center(child: CircularProgressIndicator())
          : pedido == null
          ? Center(
              child: viewModel.erro != null
                  ? MensagemErro(viewModel.erro)
                  : const Text('Pedido não encontrado.'),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CartaoCliente(pedido),
                const SizedBox(height: 16),
                ItensPedido(pedido),
                const SizedBox(height: 16),
                HistoricoPedido(pedido),
                const SizedBox(height: 16),
                BlocoRota(viewModel: viewModel, pedido: pedido),
                const SizedBox(height: 16),
                ..._acoes(context, viewModel, pedido),
              ],
            ),
    );
  }

  List<Widget> _acoes(
    BuildContext context,
    DetalhePedidoViewModel viewModel,
    Pedido pedido,
  ) {
    final livre = !viewModel.processando;
    return switch (pedido.situacao) {
      SituacaoPedido.aguardando => [
        FilledButton(
          onPressed: livre
              ? () => _abrirDialogo(
                  context,
                  viewModel,
                  DialogoTexto(
                    titulo: 'Aceitar pedido',
                    rotulo: 'Tempo estimado (min)',
                    confirmar: 'Aceitar',
                    numerico: true,
                    acao: viewModel.aceitar,
                  ),
                )
              : null,
          child: const Text('Aceitar'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: livre
              ? () => _abrirDialogo(
                  context,
                  viewModel,
                  DialogoTexto(
                    titulo: 'Recusar pedido',
                    rotulo: 'Motivo da recusa',
                    confirmar: 'Recusar',
                    numerico: false,
                    destrutivo: true,
                    acao: viewModel.recusar,
                  ),
                )
              : null,
          child: const Text('Recusar'),
        ),
      ],
      SituacaoPedido.aceito => [
        AvisoDestaque(
          icone: Icons.timer_outlined,
          titulo: 'Tempo estimado de entrega',
          texto: '${pedido.tempoEstimadoMinutos ?? 0} min',
          cor: CoresDiskGas.azulEscuro,
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: livre
              ? () => _abrirDialogo(
                  context,
                  viewModel,
                  DialogoEntrega(pedido: pedido),
                )
              : null,
          child: const Text('Finalizar entrega'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: livre
              ? () => _abrirDialogo(
                  context,
                  viewModel,
                  DialogoTexto(
                    titulo: 'Ampliar tempo',
                    rotulo: 'Minutos a mais',
                    confirmar: 'Ampliar',
                    numerico: true,
                    acao: viewModel.ampliarTempo,
                  ),
                )
              : null,
          child: const Text('Ampliar tempo'),
        ),
      ],
      SituacaoPedido.entregue || SituacaoPedido.recusado => [],
    };
  }
}
