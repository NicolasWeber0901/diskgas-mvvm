import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/pedido.dart';
import '../models/situacao_pedido.dart';
import '../services/falhas.dart';
import '../services/pedido_service.dart';

/// US10: pedidos recebidos, com os que aguardam primeiro.
class PedidosViewModel extends ChangeNotifier {
  final PedidoService _pedidoService;
  StreamSubscription<List<Pedido>>? _inscricao;

  List<Pedido> pedidos = [];
  bool carregando = true;
  String? erro;

  PedidosViewModel(this._pedidoService);

  void iniciar() {
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
