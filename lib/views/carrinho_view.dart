import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/produto.dart';
import '../viewmodels/carrinho_viewmodel.dart';
import 'widgets/botao_sair.dart';
import 'widgets/formatos.dart';
import 'widgets/mensagem_erro.dart';

/// Tela inicial do cliente: montar o carrinho e enviar o pedido (US05, US06).
class CarrinhoView extends StatelessWidget {
  const CarrinhoView({super.key});

  Future<void> _enviar(
    BuildContext context,
    CarrinhoViewModel viewModel,
  ) async {
    final endereco = viewModel.enderecoEntrega;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enviar pedido?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in viewModel.itens)
              Text('${item.quantidade}x ${item.produto.nome}'),
            const SizedBox(height: 8),
            Text(
              'Total: ${formatarPreco(viewModel.valorTotal)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Entrega em:'),
            Text(endereco?.textoCompleto ?? 'endereço do seu cadastro'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;
    final id = await viewModel.enviarPedido();
    if (id != null && context.mounted) context.go('/cliente/pedidos');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CarrinhoViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fazer pedido'),
        actions: [
          IconButton(
            tooltip: 'Meus pedidos',
            icon: const Icon(Icons.receipt_long),
            onPressed: () => context.go('/cliente/pedidos'),
          ),
          const BotaoSair(),
        ],
      ),
      body: viewModel.carregando
          ? const Center(child: CircularProgressIndicator())
          : viewModel.produtos.isEmpty
          ? const Center(child: Text('Nenhum produto cadastrado.'))
          : ListView(
              children: [
                for (final produto in viewModel.produtos)
                  _LinhaProduto(produto: produto, viewModel: viewModel),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MensagemErro(viewModel.erro),
              Text(
                'Total: ${formatarPreco(viewModel.valorTotal)}',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: viewModel.enviando || viewModel.itens.isEmpty
                    ? null
                    : () => _enviar(context, viewModel),
                child: viewModel.enviando
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enviar pedido'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinhaProduto extends StatelessWidget {
  final Produto produto;
  final CarrinhoViewModel viewModel;

  const _LinhaProduto({required this.produto, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final quantidade = viewModel.quantidadeDe(produto);
    final disponivel = produto.quantidadeEstoque > 0;
    return ListTile(
      title: Text(produto.nome),
      subtitle: Text(
        disponivel ? formatarPreco(produto.preco) : 'Indisponível',
      ),
      enabled: disponivel || quantidade > 0,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Diminuir',
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: quantidade == 0
                ? null
                : () => viewModel.alterarQuantidade(produto, quantidade - 1),
          ),
          Text('$quantidade'),
          IconButton(
            tooltip: 'Aumentar',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: disponivel
                ? () => viewModel.alterarQuantidade(produto, quantidade + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
