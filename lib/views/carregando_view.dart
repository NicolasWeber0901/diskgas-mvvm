import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/sessao_viewmodel.dart';
import 'widgets/mensagem_erro.dart';

/// US01 e US02: espera a sessão descobrir o perfil do usuário.
class CarregandoView extends StatelessWidget {
  const CarregandoView({super.key});

  @override
  Widget build(BuildContext context) {
    final sessao = context.watch<SessaoViewModel>();
    return Scaffold(
      body: Center(
        child: sessao.estado == EstadoSessao.falha
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MensagemErro(sessao.erro),
                  FilledButton(
                    onPressed: sessao.atualizar,
                    child: const Text('Tentar novamente'),
                  ),
                  TextButton(onPressed: sessao.sair, child: const Text('Sair')),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
