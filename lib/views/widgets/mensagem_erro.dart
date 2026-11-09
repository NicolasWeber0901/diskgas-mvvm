import 'package:flutter/material.dart';

import '../tema.dart';

class MensagemErro extends StatelessWidget {
  final String? mensagem;

  const MensagemErro(this.mensagem, {super.key});

  @override
  Widget build(BuildContext context) {
    final texto = mensagem;
    return AnimatedSize(
      duration: MovimentoDiskGas.duracao(context, MovimentoDiskGas.rapido),
      curve: MovimentoDiskGas.curva,
      alignment: Alignment.topCenter,
      child: texto == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                texto,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}
