import 'package:flutter/material.dart';

import '../tema.dart';

class TextoAnimado extends StatelessWidget {
  final String texto;
  final TextStyle? estilo;

  const TextoAnimado(this.texto, {this.estilo, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: MovimentoDiskGas.duracao(context, MovimentoDiskGas.rapido),
      transitionBuilder: (filho, animacao) => FadeTransition(
        opacity: animacao,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1).animate(animacao),
          child: filho,
        ),
      ),
      child: Text(
        texto,
        key: ValueKey(texto),
        textAlign: TextAlign.center,
        style: estilo,
      ),
    );
  }
}
