import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/item_pedido.dart';
import '../models/pedido.dart';
import '../models/situacao_pedido.dart';
import '../viewmodels/acompanhamento_viewmodel.dart';
import 'widgets/botao_sair.dart';
import 'widgets/formatos.dart';
import 'widgets/mensagem_erro.dart';

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
          ? const Center(child: Text('Você ainda não fez nenhum pedido.'))
          : ListView(
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

  String _textoItem(ItemPedido item) {
    final texto = '${item.quantidadePedida}x ${item.nomeProduto}';
    final entregue = item.quantidadeEntregue;
    if (entregue == null || entregue == item.quantidadePedida) return texto;
    return '$texto (entregue: $entregue)';
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        '${formatarData(pedido.dataCriacao)} - '
        '${formatarPreco(pedido.valorTotal)}',
      ),
      subtitle: Text(pedido.situacao.rotulo),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        for (final item in pedido.itens) Text(_textoItem(item)),
        const SizedBox(height: 8),
        if (pedido.situacao == SituacaoPedido.aceito &&
            pedido.tempoEstimadoMinutos != null)
          Text('Tempo estimado de entrega: ${pedido.tempoEstimadoMinutos} min'),
        // RN05: o motivo da recusa fica visível ao cliente.
        if (pedido.situacao == SituacaoPedido.recusado)
          Text('Motivo da recusa: ${pedido.motivoRecusa ?? ''}'),
        if (pedido.situacao == SituacaoPedido.entregue &&
            pedido.dataEntrega != null)
          Text('Entregue em ${formatarData(pedido.dataEntrega!)}'),
      ],
    );
  }
}
