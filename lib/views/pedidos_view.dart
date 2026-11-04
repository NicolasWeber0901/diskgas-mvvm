import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/pedidos_viewmodel.dart';
import 'widgets/botao_sair.dart';
import 'widgets/formatos.dart';
import 'widgets/mensagem_erro.dart';

/// Tela inicial do administrador: pedidos recebidos (US10).
class PedidosView extends StatelessWidget {
  const PedidosView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PedidosViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        actions: [
          IconButton(
            tooltip: 'Estoque',
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () => context.go('/admin/estoque'),
          ),
          const BotaoSair(),
        ],
      ),
      body: viewModel.carregando
          ? const Center(child: CircularProgressIndicator())
          : viewModel.erro != null
          ? Center(child: MensagemErro(viewModel.erro))
          : viewModel.pedidos.isEmpty
          ? const Center(child: Text('Nenhum pedido recebido.'))
          : ListView(
              children: [
                for (final pedido in viewModel.pedidos)
                  ListTile(
                    title: Text(pedido.clienteNome),
                    subtitle: Text(
                      '${formatarData(pedido.dataCriacao)} · '
                      '${formatarPreco(pedido.valorTotal)}',
                    ),
                    trailing: Text(pedido.situacao.rotulo),
                    onTap: () => context.go('/admin/pedidos/${pedido.id}'),
                  ),
              ],
            ),
    );
  }
}
