import 'package:flutter/material.dart';

import '../tema.dart';

class EstadoVazio extends StatelessWidget {
  final IconData icone;
  final String mensagem;

  const EstadoVazio({required this.icone, required this.mensagem, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 56, color: CoresDiskGas.cinzaQuente),
            const SizedBox(height: 12),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: CoresDiskGas.cinzaQuente),
            ),
          ],
        ),
      ),
    );
  }
}
