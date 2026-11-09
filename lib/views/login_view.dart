import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/login_viewmodel.dart';
import 'tema.dart';
import 'widgets/botao_carregando.dart';
import 'widgets/campo_senha.dart';
import 'widgets/entrada_animada.dart';
import 'widgets/mensagem_erro.dart';

/// US01 e US02.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _email = TextEditingController();
  final _senha = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  void _entrar(LoginViewModel viewModel) {
    if (viewModel.carregando) return;
    FocusScope.of(context).unfocus();
    viewModel.entrarComEmail(_email.text, _senha.text);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const EntradaAnimada(child: _Marca()),
                  const SizedBox(height: 36),
                  EntradaAnimada(
                    ordem: 1,
                    child: TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.alternate_email_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  EntradaAnimada(
                    ordem: 2,
                    child: CampoSenha(
                      controlador: _senha,
                      dicaAutomatica: AutofillHints.password,
                      aoEnviar: () => _entrar(viewModel),
                    ),
                  ),
                  MensagemErro(viewModel.erro),
                  const SizedBox(height: 12),
                  EntradaAnimada(
                    ordem: 3,
                    child: BotaoCarregando(
                      rotulo: 'Entrar',
                      carregando: viewModel.carregando,
                      aoPressionar: () => _entrar(viewModel),
                    ),
                  ),
                  const SizedBox(height: 8),
                  EntradaAnimada(
                    ordem: 4,
                    child: OutlinedButton.icon(
                      onPressed: viewModel.carregando
                          ? null
                          : viewModel.entrarComGoogle,
                      icon: const Icon(Icons.account_circle),
                      label: const Text('Entrar com a conta Google'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  EntradaAnimada(
                    ordem: 5,
                    child: TextButton(
                      onPressed: () => context.push('/cadastro'),
                      child: const Text('Ainda não tem cadastro? Cadastre-se'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Marca extends StatelessWidget {
  const _Marca();

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: CoresDiskGas.laranja,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: CoresDiskGas.azulAgua,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.water_drop_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Disk Gás\ne Água',
          style: textos.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1.0,
            letterSpacing: -1.2,
          ),
        ),
      ],
    );
  }
}
