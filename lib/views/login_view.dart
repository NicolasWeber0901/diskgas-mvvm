import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/login_viewmodel.dart';
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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.local_fire_department, size: 64),
                Text(
                  'Disk Gás e Água',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _senha,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Senha'),
                ),
                MensagemErro(viewModel.erro),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: viewModel.carregando
                      ? null
                      : () =>
                            viewModel.entrarComEmail(_email.text, _senha.text),
                  child: const Text('Entrar'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: viewModel.carregando
                      ? null
                      : viewModel.entrarComGoogle,
                  icon: const Icon(Icons.account_circle),
                  label: const Text('Entrar com a conta Google'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.push('/cadastro'),
                  child: const Text('Ainda não tem cadastro? Cadastre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
