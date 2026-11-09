import 'package:flutter/material.dart';

import '../tema.dart';

const _ordemMaxima = 5;
const _atrasoPorOrdem = 0.07;

class EntradaAnimada extends StatelessWidget {
  final int ordem;
  final Widget child;

  const EntradaAnimada({required this.child, this.ordem = 0, super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: MovimentoDiskGas.duracao(context, MovimentoDiskGas.lento),
      curve: Interval(
        ordem.clamp(0, _ordemMaxima) * _atrasoPorOrdem,
        1,
        curve: MovimentoDiskGas.curva,
      ),
      builder: (context, valor, filho) => Opacity(
        opacity: valor,
        child: Transform.translate(
          offset: Offset(0, (1 - valor) * 16),
          child: filho,
        ),
      ),
      child: child,
    );
  }
}
