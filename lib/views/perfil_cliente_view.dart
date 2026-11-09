import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/perfil_cliente_viewmodel.dart';
import 'perfil_cliente/cabecalho_cliente.dart';
import 'perfil_cliente/dados_cliente.dart';
import 'perfil_cliente/resumo_cliente.dart';
import 'tema.dart';
import 'widgets/botao_sair.dart';
import 'widgets/cartao_pedido.dart';
import 'widgets/estado_vazio.dart';
import 'widgets/formatos.dart';
import 'widgets/mensagem_erro.dart';

/// Perfil do cliente com o histórico de pedidos (US16).
class PerfilClienteView extends StatelessWidget {
  const PerfilClienteView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PerfilClienteViewModel>();
    final cliente = viewModel.cliente;
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/admin/clientes'),
        ),
        title: const Text('Cliente'),
        actions: const [BotaoSair()],
      ),
      body: viewModel.carregando
          ? const Center(child: CircularProgressIndicator())
          : cliente == null
          ? Center(
              child: viewModel.erro != null
                  ? MensagemErro(viewModel.erro)
                  : const Text('Cliente não encontrado.'),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CabecalhoCliente(cliente),
                const SizedBox(height: 16),
                ResumoCliente(viewModel),
                const SizedBox(height: 16),
                DadosCliente(cliente),
                const SizedBox(height: 24),
                Text('Histórico de pedidos', style: textos.titleMedium),
                const SizedBox(height: 8),
                if (viewModel.pedidos.isEmpty)
                  const EstadoVazio(
                    icone: Icons.receipt_long_outlined,
                    mensagem: 'Este cliente ainda não fez pedidos.',
                  ),
                for (final pedido in viewModel.pedidos)
                  CartaoPedido(
                    pedido: pedido,
                    margem: const EdgeInsets.only(bottom: 12),
                    titulo: Text(
                      formatarPreco(pedido.valorFinal),
                      style: textos.titleMedium?.copyWith(
                        color: CoresDiskGas.verde,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitulo: Text(
                      '${formatarData(pedido.dataCriacao)}\n'
                      '${pedido.itens.map((item) => '${item.quantidadePedida}x ${item.nomeProduto}').join(', ')}',
                    ),
                  ),
              ],
            ),
    );
  }
}
