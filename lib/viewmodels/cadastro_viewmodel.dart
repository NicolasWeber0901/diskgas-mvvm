import 'package:flutter/foundation.dart';

import '../models/cliente.dart';
import '../models/endereco.dart';
import '../services/auth_service.dart';
import '../services/cliente_service.dart';
import '../services/falhas.dart';

/// US04, com as regras RN02 (endereço completo) e RN03 (CPF válido).
class CadastroViewModel extends ChangeNotifier {
  final AuthService _authService;
  final ClienteService _clienteService;

  final bool completandoCadastro;

  bool carregando = false;
  String? erro;
  Map<String, String> errosDosCampos = {};

  CadastroViewModel(this._authService, this._clienteService)
    : completandoCadastro = _authService.uidAtual != null;

  Future<bool> cadastrar({
    required String nome,
    required String telefone,
    required String cpf,
    required DateTime? dataNascimento,
    required Endereco endereco,
    String email = '',
    String senha = '',
  }) async {
    final cpfNumeros = cpf.replaceAll(RegExp(r'\D'), '');
    errosDosCampos = _validar(
      nome: nome.trim(),
      telefone: telefone.trim(),
      cpf: cpfNumeros,
      dataNascimento: dataNascimento,
      endereco: endereco,
      email: email.trim(),
      senha: senha,
    );
    erro = errosDosCampos.isEmpty ? null : 'Corrija os campos indicados.';
    if (errosDosCampos.isNotEmpty) {
      notifyListeners();
      return false;
    }

    carregando = true;
    notifyListeners();
    try {
      if (await _clienteService.cpfJaCadastrado(cpfNumeros)) {
        errosDosCampos = {'cpf': 'Este CPF já está cadastrado.'};
        erro = 'Este CPF já está cadastrado.';
        return false;
      }
      final uid = completandoCadastro
          ? _authService.uidAtual!
          : await _authService.criarConta(email.trim(), senha);
      await _clienteService.salvar(
        Cliente(
          id: uid,
          nome: nome.trim(),
          telefone: telefone.trim(),
          cpf: cpfNumeros,
          dataNascimento: dataNascimento!,
          endereco: endereco,
          email: completandoCadastro
              ? _authService.emailAtual ?? ''
              : email.trim(),
        ),
      );
      return true;
    } on FalhaServico catch (e) {
      erro = e.mensagem;
      return false;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  bool validarCampos(
    Set<String> campos, {
    required String nome,
    required String telefone,
    required String cpf,
    required DateTime? dataNascimento,
    required Endereco endereco,
    String email = '',
    String senha = '',
  }) {
    final erros = _validar(
      nome: nome.trim(),
      telefone: telefone.trim(),
      cpf: cpf.replaceAll(RegExp(r'\D'), ''),
      dataNascimento: dataNascimento,
      endereco: endereco,
      email: email.trim(),
      senha: senha,
    );
    errosDosCampos = {
      for (final erro in erros.entries)
        if (campos.contains(erro.key)) erro.key: erro.value,
    };
    erro = null;
    notifyListeners();
    return errosDosCampos.isEmpty;
  }

  Map<String, String> _validar({
    required String nome,
    required String telefone,
    required String cpf,
    required DateTime? dataNascimento,
    required Endereco endereco,
    required String email,
    required String senha,
  }) {
    final erros = <String, String>{};
    if (nome.isEmpty) erros['nome'] = 'Informe o nome.';
    if (telefone.replaceAll(RegExp(r'\D'), '').length != 11) {
      erros['telefone'] = 'Informe o celular com DDD, 11 dígitos.';
    }
    // RN03: CPF válido, conferido pelos dois dígitos verificadores.
    if (!cpfValido(cpf)) erros['cpf'] = 'CPF inválido';
    if (dataNascimento == null) {
      erros['dataNascimento'] = 'Informe a data de nascimento.';
    } else if (dataNascimento.isAfter(DateTime.now())) {
      erros['dataNascimento'] = 'Data de nascimento inválida.';
    }

    // RN02: o endereço precisa estar completo.
    if (endereco.rua.trim().isEmpty) erros['rua'] = 'Informe a rua.';
    if (endereco.numero.trim().isEmpty) erros['numero'] = 'Informe o número.';
    if (endereco.bairro.trim().isEmpty) erros['bairro'] = 'Informe o bairro.';
    if (endereco.cidade.trim().isEmpty) erros['cidade'] = 'Informe a cidade.';

    if (!completandoCadastro) {
      if (!email.contains('@')) erros['email'] = 'Informe um e-mail válido.';
      if (senha.length < 6) {
        erros['senha'] = 'A senha deve ter no mínimo seis caracteres.';
      }
    }
    return erros;
  }

  static bool cpfValido(String cpf) {
    if (!RegExp(r'^\d{11}$').hasMatch(cpf)) return false;
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) return false;
    final digitos = cpf.split('').map(int.parse).toList();
    int verificador(int tamanho) {
      var soma = 0;
      for (var i = 0; i < tamanho; i++) {
        soma += digitos[i] * (tamanho + 1 - i);
      }
      final resto = (soma * 10) % 11;
      return resto == 10 ? 0 : resto;
    }

    return verificador(9) == digitos[9] && verificador(10) == digitos[10];
  }
}
