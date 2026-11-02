import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/perfil.dart';
import '../services/auth_service.dart';
import '../services/falhas.dart';

enum EstadoSessao {
  carregando,
  deslogado,
  cadastroPendente,
  cliente,
  administrador,
  falha,
}

/// Quem está logado e com qual perfil; decide a tela inicial (US01 a US03).
class SessaoViewModel extends ChangeNotifier {
  final AuthService _authService;
  StreamSubscription<String?>? _inscricao;
  int _consulta = 0;

  EstadoSessao estado = EstadoSessao.carregando;
  String? erro;

  SessaoViewModel(this._authService);

  void iniciar() {
    _inscricao = _authService.observarUsuario().listen(_aoMudarUsuario);
  }

  Future<void> atualizar() => _aoMudarUsuario(_authService.uidAtual);

  Future<void> sair() => _authService.sair();

  Future<void> _aoMudarUsuario(String? uid) async {
    final consulta = ++_consulta;
    if (uid == null) {
      _mudar(EstadoSessao.deslogado);
      return;
    }
    try {
      final perfil = await _authService.buscarPerfil(uid);
      if (consulta != _consulta) return;
      _mudar(switch (perfil) {
        Perfil.cliente => EstadoSessao.cliente,
        Perfil.administrador => EstadoSessao.administrador,
        null => EstadoSessao.cadastroPendente,
      });
    } on FalhaServico catch (e) {
      if (consulta != _consulta) return;
      _mudar(EstadoSessao.falha, erro: e.mensagem);
    }
  }

  void _mudar(EstadoSessao novo, {String? erro}) {
    estado = novo;
    this.erro = erro;
    notifyListeners();
  }

  @override
  void dispose() {
    _inscricao?.cancel();
    super.dispose();
  }
}
