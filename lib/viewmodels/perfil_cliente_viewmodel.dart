import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/cliente.dart';
import '../models/pedido.dart';
import '../models/situacao_pedido.dart';
import '../services/cliente_service.dart';
import '../services/falhas.dart';
import '../services/pedido_service.dart';

/// US16: perfil do cliente com o histórico e o resumo dos pedidos.
class PerfilClienteViewModel extends ChangeNotifier {
  final ClienteService _clienteService;
  final PedidoService _pedidoService;
  StreamSubscription<List<Pedido>>? _inscricao;
  bool _descartado = false;

  Cliente? cliente;
  List<Pedido> pedidos = [];
  bool carregando = true;
  String? erro;

  PerfilClienteViewModel(this._clienteService, this._pedidoService);

  void iniciar(String clienteId) {
    _carregarCliente(clienteId);
    _inscricao = _pedidoService
        .observarPedidosDoCliente(clienteId)
        .listen(
          (lista) {
            pedidos = [...lista]
              ..sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));
            notifyListeners();
          },
          onError: (Object _) {
            erro = const FalhaConexao().mensagem;
            notifyListeners();
          },
        );
  }

  Future<void> _carregarCliente(String clienteId) async {
    try {
      final encontrado = await _clienteService.buscar(clienteId);
      if (_descartado) return;
      cliente = encontrado;
    } on FalhaServico catch (e) {
      if (_descartado) return;
      erro = e.mensagem;
    }
    carregando = false;
    notifyListeners();
  }

  int get totalDePedidos => pedidos.length;

  int get pedidosEntregues => pedidos
      .where((pedido) => pedido.situacao == SituacaoPedido.entregue)
      .length;

  double get totalGasto => pedidos
      .where((pedido) => pedido.situacao == SituacaoPedido.entregue)
      .fold(0, (total, pedido) => total + pedido.valorFinal);

  DateTime? get ultimoPedido =>
      pedidos.isEmpty ? null : pedidos.first.dataCriacao;

  @override
  void dispose() {
    _descartado = true;
    _inscricao?.cancel();
    super.dispose();
  }
}
