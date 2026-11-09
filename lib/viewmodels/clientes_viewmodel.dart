import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/cliente.dart';
import '../models/pedido.dart';
import '../services/cliente_service.dart';
import '../services/falhas.dart';
import '../services/pedido_service.dart';
import 'normalizar_busca.dart';

/// US16: lista de clientes com a quantidade de pedidos e a busca por nome.
class ClientesViewModel extends ChangeNotifier {
  final ClienteService _clienteService;
  final PedidoService _pedidoService;
  StreamSubscription<List<Cliente>>? _inscricaoClientes;
  StreamSubscription<List<Pedido>>? _inscricaoPedidos;
  Map<String, int> _quantidades = {};

  List<Cliente> clientes = [];
  String busca = '';
  bool carregando = true;
  String? erro;

  ClientesViewModel(this._clienteService, this._pedidoService);

  void iniciar() {
    _inscricaoClientes = _clienteService.observarClientes().listen((lista) {
      clientes = [...lista]
        ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      carregando = false;
      erro = null;
      notifyListeners();
    }, onError: (Object _) => _falhar());
    _inscricaoPedidos = _pedidoService.observarTodos().listen((pedidos) {
      final quantidades = <String, int>{};
      for (final pedido in pedidos) {
        quantidades[pedido.clienteId] =
            (quantidades[pedido.clienteId] ?? 0) + 1;
      }
      _quantidades = quantidades;
      notifyListeners();
    }, onError: (Object _) => _falhar());
  }

  void _falhar() {
    carregando = false;
    erro = const FalhaConexao().mensagem;
    notifyListeners();
  }

  List<Cliente> get clientesFiltrados {
    final termo = normalizarBusca(busca);
    if (termo.isEmpty) return clientes;
    return [
      for (final cliente in clientes)
        if (normalizarBusca(cliente.nome).contains(termo)) cliente,
    ];
  }

  int quantidadeDePedidos(Cliente cliente) => _quantidades[cliente.id] ?? 0;

  void buscar(String texto) {
    busca = texto;
    notifyListeners();
  }

  @override
  void dispose() {
    _inscricaoClientes?.cancel();
    _inscricaoPedidos?.cancel();
    super.dispose();
  }
}
