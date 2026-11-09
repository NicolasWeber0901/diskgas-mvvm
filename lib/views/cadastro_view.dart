import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/endereco.dart';
import '../viewmodels/cadastro_viewmodel.dart';
import '../viewmodels/sessao_viewmodel.dart';
import 'cadastro/campo_cadastro.dart';
import 'cadastro/indicador_etapas.dart';
import 'tema.dart';
import 'widgets/aviso_destaque.dart';
import 'widgets/botao_carregando.dart';
import 'widgets/botao_sair.dart';
import 'widgets/botoes_dialogo.dart';
import 'widgets/campo_senha.dart';
import 'widgets/formatos.dart';
import 'widgets/mascaras.dart';
import 'widgets/mensagem_erro.dart';

const _etapas = [
  (
    titulo: 'Seus dados',
    descricao: 'Para identificar você nas entregas.',
    icone: Icons.person_rounded,
    campos: {'nome', 'cpf', 'dataNascimento', 'telefone'},
  ),
  (
    titulo: 'Endereço de entrega',
    descricao: 'É aqui que o gás e a água vão chegar.',
    icone: Icons.place_rounded,
    campos: {'rua', 'numero', 'bairro', 'cidade'},
  ),
  (
    titulo: 'Acesso',
    descricao: 'Com o e-mail e a senha você entra no app.',
    icone: Icons.lock_rounded,
    campos: {'email', 'senha'},
  ),
];

const _cidadePadrao = 'Dona Emma';
const _espacoEntreCampos = SizedBox(height: 16);

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
      'cpf',
      'data',
      'telefone',
      'rua',
      'numero',
      'bairro',
      'cidade',
      'email',
      'senha',
    ])
      campo: TextEditingController(),
  };
  final _rolagem = ScrollController();
  int _etapa = 0;
  bool _avancando = true;

  @override
  void initState() {
    super.initState();
    _campos['cidade']!.text = _cidadePadrao;
  }

  @override
  void dispose() {
    for (final controlador in _campos.values) {
      controlador.dispose();
    }
    _rolagem.dispose();
    super.dispose();
  }

  String get _telefone =>
      _campos['telefone']!.text.replaceAll(RegExp(r'\D'), '');

  Endereco get _endereco => Endereco(
    rua: _campos['rua']!.text,
    numero: _campos['numero']!.text,
    bairro: _campos['bairro']!.text,
    cidade: _campos['cidade']!.text,
  );

  DateTime? get _dataNascimento {
    final partes = _campos['data']!.text.split('/');
    if (partes.length != 3 || partes[2].length != 4) return null;
    final dia = int.tryParse(partes[0]);
    final mes = int.tryParse(partes[1]);
    final ano = int.tryParse(partes[2]);
    if (dia == null || mes == null || ano == null) return null;
    final data = DateTime(ano, mes, dia);
    return data.day == dia && data.month == mes ? data : null;
  }

  bool get _temDados => _campos.entries.any(
    (campo) => campo.key == 'cidade'
        ? campo.value.text != _cidadePadrao
        : campo.value.text.isNotEmpty,
  );

  void _irPara(int destino) {
    if (destino == _etapa) return;
    FocusScope.of(context).unfocus();
    if (_rolagem.hasClients) _rolagem.jumpTo(0);
    setState(() {
      _avancando = destino > _etapa;
      _etapa = destino;
    });
  }

  Future<void> _escolherData() async {
    FocusScope.of(context).unfocus();
    final hoje = DateTime.now();
    final primeira = DateTime(1900);
    final informada = _dataNascimento;
    final data = await showDatePicker(
      context: context,
      initialDate:
          informada != null &&
              !informada.isAfter(hoje) &&
              !informada.isBefore(primeira)
          ? informada
          : DateTime(2000),
      firstDate: primeira,
      lastDate: hoje,
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Data de nascimento',
    );
    if (data != null) _campos['data']!.text = formatarDataCurta(data);
  }

  void _continuar(CadastroViewModel viewModel, int totalDeEtapas) {
    if (viewModel.carregando) return;
    final valido = viewModel.validarCampos(
      _etapas[_etapa].campos,
      nome: _campos['nome']!.text,
      telefone: _telefone,
      cpf: _campos['cpf']!.text,
      dataNascimento: _dataNascimento,
      endereco: _endereco,
      email: _campos['email']!.text,
      senha: _campos['senha']!.text,
    );
    if (!valido) return;
    if (_etapa < totalDeEtapas - 1) {
      _irPara(_etapa + 1);
    } else {
      _cadastrar(viewModel);
    }
  }

  Future<void> _cadastrar(CadastroViewModel viewModel) async {
    final sessao = context.read<SessaoViewModel>();
    FocusScope.of(context).unfocus();
    final concluido = await viewModel.cadastrar(
      nome: _campos['nome']!.text,
      telefone: _telefone,
      cpf: _campos['cpf']!.text,
      dataNascimento: _dataNascimento,
      endereco: _endereco,
      email: _campos['email']!.text,
      senha: _campos['senha']!.text,
    );
    if (concluido) {
      await sessao.atualizar();
      return;
    }
    final comErro = _etapas.indexWhere(
      (etapa) => etapa.campos.any(viewModel.errosDosCampos.containsKey),
    );
    if (comErro != -1 && mounted) _irPara(comErro);
  }

  Future<void> _voltar(CadastroViewModel viewModel) async {
    if (viewModel.carregando) return;
    if (_etapa > 0) {
      _irPara(_etapa - 1);
      return;
    }
    final navegador = Navigator.of(context);
    if (!_temDados) {
      navegador.pop();
      return;
    }
    final descartar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar o cadastro?'),
        content: const Text('Os dados preenchidos serão perdidos.'),
        actions: [
          BotoesDialogo(
            confirmar: 'Descartar',
            destrutivo: true,
            aoConfirmar: () => Navigator.pop(context, true),
            cancelar: 'Continuar',
            aoCancelar: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
    if (descartar == true && mounted) navegador.pop();
  }

  Widget _dadosPessoais(Map<String, String> erros) {
    return Column(
      children: [
        CampoCadastro(
          controlador: _campos['nome']!,
          rotulo: 'Nome completo',
          erro: erros['nome'],
          icone: Icons.person_outline_rounded,
          capitalizacao: TextCapitalization.words,
          dicaAutomatica: AutofillHints.name,
        ),
        _espacoEntreCampos,
        CampoCadastro(
          controlador: _campos['cpf']!,
          rotulo: 'CPF',
          erro: erros['cpf'],
          icone: Icons.badge_outlined,
          teclado: TextInputType.number,
          mascara: MascaraNumerica.cpf,
        ),
        _espacoEntreCampos,
        CampoCadastro(
          controlador: _campos['data']!,
          rotulo: 'Data de nascimento',
          erro: erros['dataNascimento'],
          icone: Icons.cake_outlined,
          teclado: TextInputType.number,
          mascara: MascaraNumerica.data,
          dicaAutomatica: AutofillHints.birthday,
          exemplo: 'dd/mm/aaaa',
          sufixo: IconButton(
            tooltip: 'Abrir calendário',
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: _escolherData,
          ),
        ),
        _espacoEntreCampos,
        CampoCadastro(
          controlador: _campos['telefone']!,
          rotulo: 'Celular',
          erro: erros['telefone'],
          icone: Icons.phone_android_rounded,
          teclado: TextInputType.phone,
          mascara: MascaraNumerica.telefone,
          dicaAutomatica: AutofillHints.telephoneNumberNational,
          exemplo: '(47) 99999-9999',
        ),
      ],
    );
  }

  Widget _enderecoEntrega(Map<String, String> erros, VoidCallback aoEnviar) {
    return Column(
      children: [
        CampoCadastro(
          controlador: _campos['rua']!,
          rotulo: 'Rua',
          erro: erros['rua'],
          icone: Icons.signpost_outlined,
          capitalizacao: TextCapitalization.words,
          dicaAutomatica: AutofillHints.streetAddressLine1,
        ),
        _espacoEntreCampos,
        CampoCadastro(
          controlador: _campos['numero']!,
          rotulo: 'Número',
          erro: erros['numero'],
          icone: Icons.tag_rounded,
        ),
        _espacoEntreCampos,
        CampoCadastro(
          controlador: _campos['bairro']!,
          rotulo: 'Bairro ou localidade',
          erro: erros['bairro'],
          icone: Icons.holiday_village_outlined,
          capitalizacao: TextCapitalization.words,
        ),
        _espacoEntreCampos,
        CampoCadastro(
          controlador: _campos['cidade']!,
          rotulo: 'Cidade',
          erro: erros['cidade'],
          icone: Icons.location_city_rounded,
          capitalizacao: TextCapitalization.words,
          dicaAutomatica: AutofillHints.addressCity,
          aoEnviar: aoEnviar,
        ),
      ],
    );
  }

  Widget _acesso(Map<String, String> erros, VoidCallback aoEnviar) {
    return Column(
      children: [
        CampoCadastro(
          controlador: _campos['email']!,
          rotulo: 'E-mail',
          erro: erros['email'],
          icone: Icons.alternate_email_rounded,
          teclado: TextInputType.emailAddress,
          dicaAutomatica: AutofillHints.email,
        ),
        _espacoEntreCampos,
        CampoSenha(
          controlador: _campos['senha']!,
          erro: erros['senha'],
          ajuda: 'Use pelo menos seis caracteres.',
          dicaAutomatica: AutofillHints.newPassword,
          aoEnviar: aoEnviar,
        ),
      ],
    );
  }

  Widget _transicaoDaEtapa(Widget filho, Animation<double> animacao) {
    final entrando = filho.key == ValueKey(_etapa);
    final sentido = entrando == _avancando ? 1.0 : -1.0;
    return FadeTransition(
      opacity: animacao,
      child: SlideTransition(
        position: Tween(
          begin: Offset(0.12 * sentido, 0),
          end: Offset.zero,
        ).animate(animacao),
        child: filho,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CadastroViewModel>();
    final erros = viewModel.errosDosCampos;
    final completando = viewModel.completandoCadastro;
    final total = completando ? 2 : _etapas.length;
    final ultima = _etapa == total - 1;
    void continuar() => _continuar(viewModel, total);

    final etapa = _etapas[_etapa];
    final campos = switch (_etapa) {
      0 => _dadosPessoais(erros),
      1 => _enderecoEntrega(erros, continuar),
      _ => _acesso(erros, continuar),
    };

    return PopScope(
      canPop: completando && _etapa == 0,
      onPopInvokedWithResult: (saiu, _) {
        if (!saiu) _voltar(viewModel);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(completando ? 'Complete o cadastro' : 'Cadastro'),
          actions: [if (completando) const BotaoSair()],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: IndicadorEtapas(atual: _etapa, total: total),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _rolagem,
                  padding: const EdgeInsets.all(16),
                  child: AnimatedSwitcher(
                    duration: MovimentoDiskGas.duracao(
                      context,
                      MovimentoDiskGas.tela,
                    ),
                    switchInCurve: MovimentoDiskGas.curva,
                    switchOutCurve: MovimentoDiskGas.curva,
                    transitionBuilder: _transicaoDaEtapa,
                    layoutBuilder: (atual, anteriores) => Stack(
                      alignment: Alignment.topCenter,
                      children: [...anteriores, ?atual],
                    ),
                    child: Column(
                      key: ValueKey(_etapa),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _CartaoEtapa(
                          titulo: etapa.titulo,
                          descricao: etapa.descricao,
                          icone: etapa.icone,
                          child: campos,
                        ),
                        if (ultima && !completando) ...[
                          const SizedBox(height: 16),
                          AvisoDestaque(
                            icone: Icons.place_rounded,
                            titulo: 'Vamos entregar em',
                            texto: _endereco.textoCompleto,
                            cor: CoresDiskGas.azulEscuro,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MensagemErro(viewModel.erro),
                    Row(
                      spacing: 12,
                      children: [
                        if (_etapa > 0)
                          Expanded(
                            flex: 2,
                            child: OutlinedButton(
                              onPressed: viewModel.carregando
                                  ? null
                                  : () => _irPara(_etapa - 1),
                              child: const Text('Voltar'),
                            ),
                          ),
                        Expanded(
                          flex: 3,
                          child: BotaoCarregando(
                            rotulo: !ultima
                                ? 'Continuar'
                                : completando
                                ? 'Concluir cadastro'
                                : 'Criar conta',
                            carregando: viewModel.carregando,
                            aoPressionar: continuar,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartaoEtapa extends StatelessWidget {
  final String titulo;
  final String descricao;
  final IconData icone;
  final Widget child;

  const _CartaoEtapa({
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: CoresDiskGas.laranja.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icone, color: CoresDiskGas.laranjaEscuro),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: textos.titleLarge),
                      Text(
                        descricao,
                        style: textos.bodyMedium?.copyWith(
                          color: CoresDiskGas.cinzaQuente,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
