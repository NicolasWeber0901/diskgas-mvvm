import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movimentacao_estoque.dart';
import '../models/tipo_movimentacao.dart';
import '../viewmodels/historico_estoque_viewmodel.dart';
import 'tema.dart';
import 'widgets/entrada_animada.dart';
import 'widgets/estado_vazio.dart';
import 'widgets/formatos.dart';
import 'widgets/mensagem_erro.dart';
import 'widgets/troca_suave.dart';

/// Histórico de entradas e saídas do estoque (US18).
class HistoricoEstoqueView extends StatelessWidget {
  const HistoricoEstoqueView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HistoricoEstoqueViewModel>();
    final movimentacoes = viewModel.movimentacoesFiltradas;
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de estoque')),
      body: TrocaSuave(
        child: viewModel.carregando
            ? const Center(child: CircularProgressIndicator())
            : viewModel.movimentacoes.isEmpty
            ? viewModel.erro != null
                  ? Center(child: MensagemErro(viewModel.erro))
                  : const EstadoVazio(
                      icone: Icons.history_rounded,
                      mensagem: 'Nenhuma movimentação registrada.',
                    )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FiltroProdutos(viewModel),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        for (final (indice, movimentacao)
                            in movimentacoes.indexed)
                          EntradaAnimada(
                            ordem: indice,
                            child: _CartaoMovimentacao(movimentacao),
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

class _FiltroProdutos extends StatelessWidget {
  final HistoricoEstoqueViewModel viewModel;

  const _FiltroProdutos(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Todos'),
            selected: viewModel.produtoSelecionado == null,
            onSelected: (_) => viewModel.escolherProduto(null),
          ),
          for (final produto in viewModel.produtos)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ChoiceChip(
                label: Text(produto.nome),
                selected: viewModel.produtoSelecionado == produto.id,
                onSelected: (_) => viewModel.escolherProduto(produto.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _CartaoMovimentacao extends StatelessWidget {
  final MovimentacaoEstoque movimentacao;

  const _CartaoMovimentacao(this.movimentacao);

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final saida = movimentacao.tipo == TipoMovimentacao.saida;
    final (icone, cor) = switch (movimentacao.tipo) {
      TipoMovimentacao.entrada => (
        Icons.south_west_rounded,
        CoresDiskGas.verde,
      ),
      TipoMovimentacao.inicial => (
        Icons.inventory_2_outlined,
        CoresDiskGas.azulAgua,
      ),
      TipoMovimentacao.saida => (
        Icons.north_east_rounded,
        CoresDiskGas.laranjaEscuro,
      ),
    };
    final cliente = movimentacao.clienteNome;
    return Card(
      child: ListTile(
        isThreeLine: true,
        leading: CircleAvatar(
          backgroundColor: cor.withValues(alpha: 0.12),
          foregroundColor: cor,
          child: Icon(icone),
        ),
        title: Text(movimentacao.nomeProduto, style: textos.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              saida && cliente != null
                  ? 'Entrega do pedido de $cliente'
                  : movimentacao.tipo.rotulo,
            ),
            Text(
              formatarData(movimentacao.data),
              style: textos.bodySmall?.copyWith(
                color: CoresDiskGas.cinzaQuente,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${saida ? '−' : '+'}${movimentacao.quantidade}',
              style: textos.titleMedium?.copyWith(
                color: cor,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text('Saldo: ${movimentacao.saldo}', style: textos.bodySmall),
          ],
        ),
      ),
    );
  }
}
