import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/botao_sair.dart';

/// Acompanhamento dos pedidos do cliente (US07).
class AcompanhamentoView extends StatelessWidget {
  const AcompanhamentoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/cliente')),
        title: const Text('Meus pedidos'),
        actions: const [BotaoSair()],
      ),
      body: const Center(child: Text('Em desenvolvimento (US07).')),
    );
  }
}
