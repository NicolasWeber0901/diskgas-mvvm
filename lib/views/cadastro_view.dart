import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/endereco.dart';
import '../viewmodels/cadastro_viewmodel.dart';
import '../viewmodels/sessao_viewmodel.dart';
import 'widgets/botao_sair.dart';
import 'widgets/formatos.dart';
import 'widgets/mascaras.dart';
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
      telefone: _campos['telefone']!.text.replaceAll(RegExp(r'\D'), ''),
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
          _CampoCadastro(
            controlador: _campos['nome']!,
            rotulo: 'Nome',
            erro: erros['nome'],
          ),
          _CampoCadastro(
            controlador: _campos['telefone']!,
            rotulo: 'Celular',
            erro: erros['telefone'],
            teclado: TextInputType.phone,
            mascara: MascaraNumerica.telefone,
          ),
          _CampoCadastro(
            controlador: _campos['cpf']!,
            rotulo: 'CPF',
            erro: erros['cpf'],
            teclado: TextInputType.number,
            mascara: MascaraNumerica.cpf,
          ),
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
                  data == null ? 'Selecionar' : formatarDataCurta(data),
                ),
              ),
            ),
          ),
          Text('Endereço', style: Theme.of(context).textTheme.titleMedium),
          _CampoCadastro(
            controlador: _campos['rua']!,
            rotulo: 'Rua',
            erro: erros['rua'],
          ),
          _CampoCadastro(
            controlador: _campos['numero']!,
            rotulo: 'Número',
            erro: erros['numero'],
          ),
          _CampoCadastro(
            controlador: _campos['bairro']!,
            rotulo: 'Bairro',
            erro: erros['bairro'],
          ),
          _CampoCadastro(
            controlador: _campos['cidade']!,
            rotulo: 'Cidade',
            erro: erros['cidade'],
          ),
          if (!viewModel.completandoCadastro) ...[
            _CampoCadastro(
              controlador: _campos['email']!,
              rotulo: 'E-mail',
              erro: erros['email'],
              teclado: TextInputType.emailAddress,
            ),
            _CampoCadastro(
              controlador: _campos['senha']!,
              rotulo: 'Senha',
              erro: erros['senha'],
              oculto: true,
            ),
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

class _CampoCadastro extends StatelessWidget {
  final TextEditingController controlador;
  final String rotulo;
  final String? erro;
  final TextInputType? teclado;
  final TextInputFormatter? mascara;
  final bool oculto;

  const _CampoCadastro({
    required this.controlador,
    required this.rotulo,
    required this.erro,
    this.teclado,
    this.mascara,
    this.oculto = false,
  });

  @override
  Widget build(BuildContext context) {
    final mascara = this.mascara;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controlador,
        keyboardType: teclado,
        inputFormatters: mascara == null ? null : [mascara],
        obscureText: oculto,
        decoration: InputDecoration(labelText: rotulo, errorText: erro),
      ),
    );
  }
}
