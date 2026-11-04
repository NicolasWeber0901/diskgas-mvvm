import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/botao_sair.dart';

/// Tela inicial do administrador (US10).
class PedidosView extends StatelessWidget {
  const PedidosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        actions: [
          IconButton(
            tooltip: 'Estoque',
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () => context.go('/admin/estoque'),
          ),
          const BotaoSair(),
        ],
      ),
      body: const Center(child: Text('Em desenvolvimento (US10).')),
    );
  }
}
