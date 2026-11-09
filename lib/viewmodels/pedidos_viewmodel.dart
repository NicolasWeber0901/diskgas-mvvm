import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/pedido.dart';
import '../models/situacao_pedido.dart';
import '../services/falhas.dart';
import '../services/pedido_service.dart';
import '../services/produto_service.dart';
import 'busca.dart';

enum PeriodoPedidos {
  hoje('Hoje'),
  seteDias('7 dias'),
  trintaDias('30 dias'),
  todos('Todos');

  final String rotulo;

  const PeriodoPedidos(this.rotulo);
}

/// US10 e US17: pedidos recebidos, com os que aguardam primeiro, e os filtros.
class PedidosViewModel extends ChangeNotifier {
  final PedidoService _pedidoService;
  final ProdutoService _produtoService;
  StreamSubscription<List<Pedido>>? _inscricao;

  final DateTime Function() _agora;

  List<Pedido> pedidos = [];
  Set<SituacaoPedido> situacoes = {};
  PeriodoPedidos periodo = PeriodoPedidos.todos;
  String busca = '';
  bool carregando = true;
  String? erro;

  PedidosViewModel(
    this._pedidoService,
    this._produtoService, {
    DateTime Function()? agora,
  }) : _agora = agora ?? DateTime.now;

  void iniciar() {
    _produtoService.garantirProdutosPadrao().onError<FalhaServico>((_, _) {});
    _inscricao = _pedidoService.observarTodos().listen(
      (lista) {
        pedidos = [...lista]..sort(_comparar);
        carregando = false;
        erro = null;
        notifyListeners();
      },
      onError: (Object _) {
        carregando = false;
        erro = const FalhaConexao().mensagem;
        notifyListeners();
      },
    );
  }

  List<Pedido> get pedidosFiltrados {
    final agora = _agora();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final inicio = switch (periodo) {
      PeriodoPedidos.hoje => hoje,
      PeriodoPedidos.seteDias => hoje.subtract(const Duration(days: 6)),
      PeriodoPedidos.trintaDias => hoje.subtract(const Duration(days: 29)),
      PeriodoPedidos.todos => null,
    };
    final termo = normalizarBusca(busca);
    return [
      for (final pedido in pedidos)
        if ((situacoes.isEmpty || situacoes.contains(pedido.situacao)) &&
            (inicio == null || !pedido.dataCriacao.isBefore(inicio)) &&
            (termo.isEmpty ||
                normalizarBusca(pedido.clienteNome).contains(termo)))
          pedido,
    ];
  }

  int get filtrosAtivos =>
      situacoes.length + (periodo == PeriodoPedidos.todos ? 0 : 1);

  bool get filtrando =>
      situacoes.isNotEmpty ||
      periodo != PeriodoPedidos.todos ||
      busca.trim().isNotEmpty;

  void alternarSituacao(SituacaoPedido situacao) {
    situacoes = {...situacoes};
    if (!situacoes.remove(situacao)) situacoes.add(situacao);
    notifyListeners();
  }

  void escolherPeriodo(PeriodoPedidos novo) {
    periodo = novo;
    notifyListeners();
  }

  void buscar(String texto) {
    busca = texto;
    notifyListeners();
  }

  void limparFiltros() {
    situacoes = {};
    periodo = PeriodoPedidos.todos;
    busca = '';
    notifyListeners();
  }

  int _grupo(SituacaoPedido situacao) => switch (situacao) {
    SituacaoPedido.aguardando => 0,
    SituacaoPedido.aceito => 1,
    SituacaoPedido.entregue || SituacaoPedido.recusado => 2,
  };

  int _comparar(Pedido a, Pedido b) {
    final grupoA = _grupo(a.situacao);
    final grupoB = _grupo(b.situacao);
    if (grupoA != grupoB) return grupoA.compareTo(grupoB);
    return grupoA == 2
        ? b.dataCriacao.compareTo(a.dataCriacao)
        : a.dataCriacao.compareTo(b.dataCriacao);
  }

  @override
  void dispose() {
    _inscricao?.cancel();
    super.dispose();
  }
}
