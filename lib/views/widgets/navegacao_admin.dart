import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../tema.dart';

class NavegacaoAdmin extends StatelessWidget {
  final int atual;

  const NavegacaoAdmin(this.atual, {super.key});

  static const _destinos = ['/admin', '/admin/clientes', '/admin/estoque'];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: atual,
      backgroundColor: Colors.white,
      indicatorColor: CoresDiskGas.laranjaBotao.withValues(alpha: 0.16),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (indice) {
        if (indice != atual) context.go(_destinos[indice]);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(
            Icons.receipt_long,
            color: CoresDiskGas.laranjaEscuro,
          ),
          label: 'Pedidos',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people, color: CoresDiskGas.laranjaEscuro),
          label: 'Clientes',
        ),
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(
            Icons.inventory_2,
            color: CoresDiskGas.laranjaEscuro,
          ),
          label: 'Estoque',
        ),
      ],
    );
  }
}
