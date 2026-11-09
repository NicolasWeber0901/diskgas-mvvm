import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/situacao_pedido.dart';
import '../viewmodels/pedidos_viewmodel.dart';
import 'tema.dart';
import 'widgets/botao_sair.dart';
import 'widgets/estado_vazio.dart';
import 'widgets/formatos.dart';
import 'widgets/mensagem_erro.dart';
import 'widgets/navegacao_admin.dart';
import 'widgets/selo_situacao.dart';

/// Tela inicial do administrador: pedidos recebidos e filtros (US10 e US17).
class PedidosView extends StatelessWidget {
  const PedidosView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PedidosViewModel>();
    final pedidos = viewModel.pedidosFiltrados;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Pedidos'),
        actions: const [BotaoSair()],
      ),
      bottomNavigationBar: const NavegacaoAdmin(0),
      body: viewModel.carregando
          ? const Center(child: CircularProgressIndicator())
          : viewModel.erro != null
          ? Center(child: MensagemErro(viewModel.erro))
          : viewModel.pedidos.isEmpty
          ? const EstadoVazio(
              icone: Icons.inbox_outlined,
              mensagem: 'Nenhum pedido recebido.',
            )
          : LayoutBuilder(
              builder: (context, limites) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: limites.maxHeight * 0.6,
                    ),
                    child: SingleChildScrollView(child: _Filtros(viewModel)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            [
                              if (viewModel.filtrando) 'Filtrando',
                              pedidos.length == 1
                                  ? '1 pedido'
                                  : '${pedidos.length} pedidos',
                            ].join(' · '),
                            style: const TextStyle(
                              color: CoresDiskGas.cinzaQuente,
                            ),
                          ),
                        ),
                        if (viewModel.filtrando)
                          TextButton(
                            onPressed: viewModel.limparFiltros,
                            child: const Text('Limpar filtros'),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 16),
                      children: [
                        if (pedidos.isEmpty)
                          const EstadoVazio(
                            icone: Icons.filter_alt_off_outlined,
                            mensagem: 'Nenhum pedido com esses filtros.',
                          ),
                        for (final pedido in pedidos)
                          Card(
                            clipBehavior: Clip.antiAlias,
                            child: ListTile(
                              title: Text(
                                pedido.clienteNome,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(formatarData(pedido.dataCriacao)),
                                  Text(
                                    formatarPreco(pedido.valorFinal),
                                    style: const TextStyle(
                                      color: CoresDiskGas.verde,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: SeloSituacao(pedido.situacao),
                              onTap: () =>
                                  context.push('/admin/pedidos/${pedido.id}'),
                            ),
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

class _Filtros extends StatefulWidget {
  final PedidosViewModel viewModel;

  const _Filtros(this.viewModel);

  @override
  State<_Filtros> createState() => _FiltrosState();
}

class _FiltrosState extends State<_Filtros> {
  late final _busca = TextEditingController(text: widget.viewModel.busca);
  bool _aberto = false;

  @override
  void didUpdateWidget(_Filtros antigo) {
    super.didUpdateWidget(antigo);
    if (widget.viewModel.busca.isEmpty && _busca.text.isNotEmpty) {
      _busca.clear();
    }
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  String _resumo(PedidosViewModel viewModel) => [
    for (final situacao in viewModel.situacoes) situacao.rotulo,
    if (viewModel.periodo != PeriodoPedidos.todos) viewModel.periodo.rotulo,
  ].join(' · ');

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final ativos = viewModel.filtrosAtivos;
    final resumo = _resumo(viewModel);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          TextField(
            controller: _busca,
            onChanged: viewModel.buscar,
            decoration: const InputDecoration(
              hintText: 'Buscar pelo nome do cliente',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _aberto || ativos > 0
                    ? CoresDiskGas.laranjaEscuro
                    : CoresDiskGas.areia,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: () => setState(() => _aberto = !_aberto),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 56),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.tune_rounded,
                            color: CoresDiskGas.laranjaEscuro,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Filtros',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                if (!_aberto && resumo.isNotEmpty)
                                  Text(
                                    resumo,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: CoresDiskGas.laranjaEscuro,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (ativos > 0)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: CoresDiskGas.laranjaEscuro,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '$ativos',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          AnimatedRotation(
                            turns: _aberto ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(Icons.expand_more_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.topCenter,
                  child: !_aberto
                      ? const SizedBox(width: double.infinity)
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: 12,
                            children: [
                              const Divider(height: 1),
                              const Text(
                                'Situação',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final situacao in SituacaoPedido.values)
                                    FilterChip(
                                      label: Text(situacao.rotulo),
                                      selected: viewModel.situacoes.contains(
                                        situacao,
                                      ),
                                      onSelected: (_) =>
                                          viewModel.alternarSituacao(situacao),
                                    ),
                                ],
                              ),
                              const Text(
                                'Período',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              SegmentedButton<PeriodoPedidos>(
                                showSelectedIcon: false,
                                segments: [
                                  for (final periodo in PeriodoPedidos.values)
                                    ButtonSegment(
                                      value: periodo,
                                      label: Text(periodo.rotulo),
                                    ),
                                ],
                                selected: {viewModel.periodo},
                                onSelectionChanged: (escolha) =>
                                    viewModel.escolherPeriodo(escolha.first),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
