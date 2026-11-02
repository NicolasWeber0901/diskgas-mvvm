import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/endereco.dart';
import '../viewmodels/cadastro_viewmodel.dart';
import '../viewmodels/sessao_viewmodel.dart';
import 'widgets/botao_sair.dart';
import 'widgets/mensagem_erro.dart';

/// US04, também no primeiro acesso com a conta Google.
class CadastroView extends StatefulWidget {
  const CadastroView({super.key});

  @override
  State<CadastroView> createState() => _CadastroViewState();
}

class _CadastroViewState extends State<CadastroView> {
  final _campos = {
    for (final campo in [
      'nome',
      'telefone',
      'cpf',
      'rua',
      'numero',
      'bairro',
      'cidade',
      'email',
      'senha',
    ])
      campo: TextEditingController(),
  };
  DateTime? _dataNascimento;

  @override
  void dispose() {
    for (final controlador in _campos.values) {
      controlador.dispose();
    }
    super.dispose();
  }

  Future<void> _escolherData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataNascimento ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (data != null) setState(() => _dataNascimento = data);
  }

  Future<void> _cadastrar(CadastroViewModel viewModel) async {
    final sessao = context.read<SessaoViewModel>();
    final concluido = await viewModel.cadastrar(
      nome: _campos['nome']!.text,
      telefone: _campos['telefone']!.text,
      cpf: _campos['cpf']!.text,
      dataNascimento: _dataNascimento,
      endereco: Endereco(
        rua: _campos['rua']!.text,
        numero: _campos['numero']!.text,
        bairro: _campos['bairro']!.text,
        cidade: _campos['cidade']!.text,
      ),
      email: _campos['email']!.text,
      senha: _campos['senha']!.text,
    );
    if (concluido) await sessao.atualizar();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CadastroViewModel>();
    final erros = viewModel.errosDosCampos;

    Widget campo(
      String nome,
      String rotulo, {
      TextInputType? teclado,
      bool oculto = false,
    }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: _campos[nome],
          keyboardType: teclado,
          obscureText: oculto,
          decoration: InputDecoration(
            labelText: rotulo,
            errorText: erros[nome],
          ),
        ),
      );
    }

    final data = _dataNascimento;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          viewModel.completandoCadastro ? 'Complete o cadastro' : 'Cadastro',
        ),
        actions: [if (viewModel.completandoCadastro) const BotaoSair()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          campo('nome', 'Nome'),
          campo('telefone', 'Telefone', teclado: TextInputType.phone),
          campo('cpf', 'CPF', teclado: TextInputType.number),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: _escolherData,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Data de nascimento',
                  errorText: erros['dataNascimento'],
                ),
                child: Text(
                  data == null
                      ? 'Selecionar'
                      : '${data.day.toString().padLeft(2, '0')}/'
                            '${data.month.toString().padLeft(2, '0')}/'
                            '${data.year}',
                ),
              ),
            ),
          ),
          Text('Endereço', style: Theme.of(context).textTheme.titleMedium),
          campo('rua', 'Rua'),
          campo('numero', 'Número'),
          campo('bairro', 'Bairro'),
          campo('cidade', 'Cidade'),
          if (!viewModel.completandoCadastro) ...[
            campo('email', 'E-mail', teclado: TextInputType.emailAddress),
            campo('senha', 'Senha', oculto: true),
          ],
          MensagemErro(viewModel.erro),
          FilledButton(
            onPressed: viewModel.carregando
                ? null
                : () => _cadastrar(viewModel),
            child: const Text('Cadastrar'),
          ),
        ],
      ),
    );
  }
}
