import 'package:flutter/material.dart';

import '../tema.dart';

class TrocaSuave extends StatelessWidget {
  final Widget child;

  const TrocaSuave({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: MovimentoDiskGas.duracao(context, MovimentoDiskGas.medio),
      switchInCurve: MovimentoDiskGas.curva,
      layoutBuilder: (atual, anteriores) =>
          Stack(fit: StackFit.expand, children: [...anteriores, ?atual]),
      child: child,
    );
  }
}
