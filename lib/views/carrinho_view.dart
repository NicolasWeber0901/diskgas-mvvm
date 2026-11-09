import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/produto.dart';
import '../viewmodels/carrinho_viewmodel.dart';
import 'tema.dart';
import 'widgets/botao_sair.dart';
import 'widgets/botoes_dialogo.dart';
import 'widgets/estado_vazio.dart';
import 'widgets/formatos.dart';
import 'widgets/icone_produto.dart';
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
            const Text('Entregar em:'),
            Text(endereco?.textoCompleto ?? 'endereço do seu cadastro'),
          ],
        ),
        actions: [
          BotoesDialogo(
            confirmar: 'Enviar',
            aoConfirmar: () => Navigator.pop(context, true),
            cancelar: 'Voltar',
            aoCancelar: () => Navigator.pop(context, false),
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
          ? const EstadoVazio(
              icone: Icons.inventory_2_outlined,
              mensagem: 'Nenhum produto cadastrado.',
            )
          : ListView(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              children: [
                _BlocoEntrega(viewModel.enderecoEntrega?.textoCompleto),
                for (final produto in viewModel.produtos)
                  _LinhaProduto(produto: produto, viewModel: viewModel),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: CoresDiskGas.areia)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MensagemErro(viewModel.erro),
                Row(
                  children: [
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(color: CoresDiskGas.cinzaQuente),
                    ),
                    const Spacer(),
                    Text(
                      formatarPreco(viewModel.valorTotal),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: viewModel.enviando || viewModel.itens.isEmpty
                      ? null
                      : () => _enviar(context, viewModel),
                  child: viewModel.enviando
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Enviar pedido'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BlocoEntrega extends StatelessWidget {
  final String? endereco;

  const _BlocoEntrega(this.endereco);

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.place_rounded, color: CoresDiskGas.laranjaEscuro),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entregar em',
                  style: textos.bodySmall?.copyWith(
                    color: CoresDiskGas.cinzaQuente,
                  ),
                ),
                Text(
                  endereco ?? 'Endereço do seu cadastro',
                  style: textos.titleMedium,
                ),
              ],
            ),
          ),
        ],
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
    final textos = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            IconeProduto(produto.id, ativo: disponivel),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(produto.nome, style: textos.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    disponivel ? formatarPreco(produto.preco) : 'Indisponível',
                    style: textos.bodyMedium?.copyWith(
                      color: disponivel
                          ? CoresDiskGas.laranjaEscuro
                          : CoresDiskGas.cinzaQuente,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: CoresDiskGas.creme,
                borderRadius: EstilosDiskGas.raioPilula,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Diminuir',
                    icon: const Icon(Icons.remove_rounded),
                    onPressed: quantidade == 0
                        ? null
                        : () => viewModel.alterarQuantidade(
                            produto,
                            quantidade - 1,
                          ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 28),
                    child: Text(
                      '$quantidade',
                      textAlign: TextAlign.center,
                      style: textos.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Aumentar',
                    color: CoresDiskGas.laranjaEscuro,
                    icon: const Icon(Icons.add_rounded),
                    onPressed: disponivel
                        ? () => viewModel.alterarQuantidade(
                            produto,
                            quantidade + 1,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
