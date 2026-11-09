import 'package:flutter/material.dart';

import '../../models/situacao_pedido.dart';
import '../../viewmodels/pedidos_viewmodel.dart';
import '../tema.dart';

class PainelFiltros extends StatefulWidget {
  final PedidosViewModel viewModel;

  const PainelFiltros(this.viewModel, {super.key});

  @override
  State<PainelFiltros> createState() => _PainelFiltrosState();
}

class _PainelFiltrosState extends State<PainelFiltros> {
  late final _busca = TextEditingController(text: widget.viewModel.busca);
  bool _aberto = false;

  @override
  void didUpdateWidget(PainelFiltros antigo) {
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

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
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
                color: _aberto || viewModel.filtrosAtivos > 0
                    ? CoresDiskGas.laranjaEscuro
                    : CoresDiskGas.areia,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CabecalhoFiltros(
                  viewModel: viewModel,
                  aberto: _aberto,
                  aoTocar: () => setState(() => _aberto = !_aberto),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.topCenter,
                  child: _aberto
                      ? _OpcoesFiltros(viewModel)
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CabecalhoFiltros extends StatelessWidget {
  final PedidosViewModel viewModel;
  final bool aberto;
  final VoidCallback aoTocar;

  const _CabecalhoFiltros({
    required this.viewModel,
    required this.aberto,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final ativos = viewModel.filtrosAtivos;
    final resumo = viewModel.resumoFiltros;
    return InkWell(
      onTap: aoTocar,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.tune_rounded, color: CoresDiskGas.laranjaEscuro),
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
                    if (!aberto && resumo.isNotEmpty)
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
              if (ativos > 0) _ContadorFiltros(ativos),
              AnimatedRotation(
                turns: aberto ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.expand_more_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContadorFiltros extends StatelessWidget {
  final int quantidade;

  const _ContadorFiltros(this.quantidade);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: const BoxDecoration(
        color: CoresDiskGas.laranjaEscuro,
        borderRadius: EstilosDiskGas.raioPilula,
      ),
      child: Text(
        '$quantidade',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _OpcoesFiltros extends StatelessWidget {
  final PedidosViewModel viewModel;

  const _OpcoesFiltros(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          const Divider(height: 1),
          const Text('Situação', style: EstilosDiskGas.negrito),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final situacao in SituacaoPedido.values)
                FilterChip(
                  label: Text(situacao.rotulo),
                  selected: viewModel.situacoes.contains(situacao),
                  onSelected: (_) => viewModel.alternarSituacao(situacao),
                ),
            ],
          ),
          const Text('Período', style: EstilosDiskGas.negrito),
          SegmentedButton<PeriodoPedidos>(
            showSelectedIcon: false,
            segments: [
              for (final periodo in PeriodoPedidos.values)
                ButtonSegment(value: periodo, label: Text(periodo.rotulo)),
            ],
            selected: {viewModel.periodo},
            onSelectionChanged: (escolha) =>
                viewModel.escolherPeriodo(escolha.first),
          ),
        ],
      ),
    );
  }
}
