import 'package:flutter/material.dart';

import 'widgets/botao_sair.dart';

/// Tela inicial do administrador (US10).
class PedidosView extends StatelessWidget {
  const PedidosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        actions: const [BotaoSair()],
      ),
      body: const Center(child: Text('Em desenvolvimento (US10).')),
    );
  }
}
