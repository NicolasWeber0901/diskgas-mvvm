import 'package:flutter/material.dart';

import 'widgets/botao_sair.dart';

/// Tela inicial do cliente (US05 e US06).
class CarrinhoView extends StatelessWidget {
  const CarrinhoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fazer pedido'),
        actions: const [BotaoSair()],
      ),
      body: const Center(child: Text('Em desenvolvimento (US05 e US06).')),
    );
  }
}
