import 'package:flutter/material.dart';

import '../tema.dart';

class BotaoCarregando extends StatelessWidget {
  final String rotulo;
  final bool carregando;
  final VoidCallback? aoPressionar;

  const BotaoCarregando({
    required this.rotulo,
    required this.carregando,
    required this.aoPressionar,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: carregando ? null : aoPressionar,
      child: AnimatedSwitcher(
        duration: MovimentoDiskGas.duracao(context, MovimentoDiskGas.rapido),
        child: carregando
            ? const SizedBox.square(
                key: ValueKey('carregando'),
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: CoresDiskGas.laranjaEscuro,
                ),
              )
            : Text(rotulo, key: ValueKey(rotulo)),
      ),
    );
  }
}
