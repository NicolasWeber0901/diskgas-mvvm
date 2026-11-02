import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/sessao_viewmodel.dart';

/// US03: sair da conta, na barra superior da tela inicial de cada perfil.
class BotaoSair extends StatelessWidget {
  const BotaoSair({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Sair',
      icon: const Icon(Icons.logout),
      onPressed: () => context.read<SessaoViewModel>().sair(),
    );
  }
}
