import 'package:flutter/material.dart';

class MensagemErro extends StatelessWidget {
  final String? mensagem;

  const MensagemErro(this.mensagem, {super.key});

  @override
  Widget build(BuildContext context) {
    if (mensagem == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        mensagem!,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
        textAlign: TextAlign.center,
      ),
    );
  }
}
