import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/pedido.dart';
import '../models/situacao_pedido.dart';
import '../viewmodels/acompanhamento_viewmodel.dart';
import 'tema.dart';
import 'widgets/botao_sair.dart';
import 'widgets/estado_vazio.dart';
import 'widgets/formatos.dart';
import 'widgets/linha_item_pedido.dart';
import 'widgets/mensagem_erro.dart';
import 'widgets/selo_situacao.dart';

/// Acompanhamento dos pedidos do cliente (US07).
class AcompanhamentoView extends StatelessWidget {
  const AcompanhamentoView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AcompanhamentoViewModel>();
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/cliente')),
        title: const Text('Meus pedidos'),
        actions: const [BotaoSair()],
      ),
      body: viewModel.carregando
          ? const Center(child: CircularProgressIndicator())
          : viewModel.erro != null
          ? Center(child: MensagemErro(viewModel.erro))
          : viewModel.pedidos.isEmpty
          ? const EstadoVazio(
              icone: Icons.receipt_long_outlined,
              mensagem: 'Você ainda não fez nenhum pedido.',
            )
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final pedido in viewModel.pedidos)
                  _CartaoPedido(pedido: pedido),
              ],
            ),
    );
  }
}

class _CartaoPedido extends StatelessWidget {
  final Pedido pedido;

  const _CartaoPedido({required this.pedido});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final tempo = pedido.tempoEstimadoMinutos;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExpansionTile(
            title: Text(
              formatarPreco(pedido.valorFinal),
              style: textos.titleMedium?.copyWith(
                color: CoresDiskGas.verde,
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Text(
              formatarData(pedido.dataCriacao),
              style: textos.bodySmall?.copyWith(
                color: CoresDiskGas.cinzaQuente,
              ),
            ),
            leading: SeloSituacao(pedido.situacao),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              for (final item in pedido.itens) LinhaItemPedido(item),
              if (pedido.situacao == SituacaoPedido.entregue &&
                  pedido.dataEntrega != null) ...[
                const SizedBox(height: 8),
                Text('Entregue em ${formatarData(pedido.dataEntrega!)}'),
              ],
            ],
          ),
          if (pedido.situacao == SituacaoPedido.aguardando ||
              pedido.situacao == SituacaoPedido.aceito)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _LinhaDoTempo(pedido.situacao),
            ),
          if (pedido.situacao == SituacaoPedido.aceito && tempo != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Chega em até '),
                    TextSpan(
                      text: '$tempo min',
                      style: textos.headlineSmall?.copyWith(
                        color: CoresDiskGas.laranjaEscuro,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // RN05: o motivo da recusa fica visível ao cliente.
          if (pedido.situacao == SituacaoPedido.recusado)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'Motivo da recusa: ${pedido.motivoRecusa ?? ''}',
                style: const TextStyle(color: CoresDiskGas.vermelho),
              ),
            ),
        ],
      ),
    );
  }
}

class _LinhaDoTempo extends StatelessWidget {
  final SituacaoPedido situacao;

  const _LinhaDoTempo(this.situacao);

  @override
  Widget build(BuildContext context) {
    const etapas = [
      SituacaoPedido.aguardando,
      SituacaoPedido.aceito,
      SituacaoPedido.entregue,
    ];
    final atual = etapas.indexOf(situacao);
    Color corDoTraco(bool visivel, bool feito) => !visivel
        ? Colors.transparent
        : feito
        ? CoresDiskGas.laranjaEscuro
        : CoresDiskGas.areia;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < etapas.length; i++)
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 3,
                        color: corDoTraco(i > 0, i <= atual),
                      ),
                    ),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i <= atual
                            ? CoresDiskGas.laranjaEscuro
                            : Colors.white,
                        border: Border.all(
                          color: i <= atual
                              ? CoresDiskGas.laranjaEscuro
                              : CoresDiskGas.bordaCampo,
                          width: 2,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 3,
                        color: corDoTraco(i < etapas.length - 1, i < atual),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  etapas[i].rotulo,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: i == atual ? FontWeight.w700 : FontWeight.w400,
                    color: i <= atual
                        ? CoresDiskGas.carvao
                        : CoresDiskGas.cinzaQuente,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
