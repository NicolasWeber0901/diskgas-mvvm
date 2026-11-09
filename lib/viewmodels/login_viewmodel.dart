import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';
import '../services/falhas.dart';

/// US01 e US02: login; a tela inicial de cada perfil é escolhida pela sessão.
class LoginViewModel extends ChangeNotifier {
  final AuthService _authService;
  bool _descartado = false;

  bool carregando = false;
  String? erro;

  LoginViewModel(this._authService);

  Future<bool> entrarComEmail(String email, String senha) async {
    if (email.trim().isEmpty || senha.isEmpty) {
      erro = 'Informe o e-mail e a senha.';
      notifyListeners();
      return false;
    }
    return _executar(() async {
      await _authService.entrarComEmail(email.trim(), senha);
      return true;
    });
  }

  Future<bool> entrarComGoogle() {
    return _executar(() async {
      final uid = await _authService.entrarComGoogle();
      return uid != null;
    });
  }

  Future<bool> _executar(Future<bool> Function() acao) async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      return await acao();
    } on FalhaServico catch (e) {
      erro = e.mensagem;
      return false;
    } finally {
      carregando = false;
      if (!_descartado) notifyListeners();
    }
  }

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }
}
