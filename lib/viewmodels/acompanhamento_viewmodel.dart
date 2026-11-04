import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/pedido.dart';
import '../services/auth_service.dart';
import '../services/falhas.dart';
import '../services/pedido_service.dart';

/// US07, com a regra RN05 (motivo da recusa visível ao cliente).
class AcompanhamentoViewModel extends ChangeNotifier {
  final AuthService _authService;
  final PedidoService _pedidoService;
  StreamSubscription<List<Pedido>>? _inscricao;

  List<Pedido> pedidos = [];
  bool carregando = true;
  String? erro;

  AcompanhamentoViewModel(this._authService, this._pedidoService);

  void iniciar() {
    _inscricao = _pedidoService
        .observarPedidosDoCliente(_authService.uidAtual!)
        .listen(
          (lista) {
            pedidos = [...lista]
              ..sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));
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

  @override
  void dispose() {
    _inscricao?.cancel();
    super.dispose();
  }
}
