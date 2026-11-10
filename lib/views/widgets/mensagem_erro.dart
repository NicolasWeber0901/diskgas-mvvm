import 'package:flutter/material.dart';

import '../tema.dart';

class MensagemErro extends StatelessWidget {
  final String? mensagem;
  final bool reservarEspaco;

  const MensagemErro(this.mensagem, {this.reservarEspaco = false, super.key});

  @override
  Widget build(BuildContext context) {
    final texto = mensagem;
    final estilo = TextStyle(color: Theme.of(context).colorScheme.error);
    if (reservarEspaco) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            ExcludeSemantics(
              child: Text('\n', style: estilo, textAlign: TextAlign.center),
            ),
            SizedBox(
              width: double.infinity,
              child: AnimatedOpacity(
                opacity: texto == null ? 0 : 1,
                duration: MovimentoDiskGas.duracao(
                  context,
                  MovimentoDiskGas.rapido,
                ),
                child: Text(
                  texto ?? '',
                  style: estilo,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return AnimatedSize(
      duration: MovimentoDiskGas.duracao(context, MovimentoDiskGas.rapido),
      curve: MovimentoDiskGas.curva,
      alignment: Alignment.topCenter,
      child: texto == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(texto, style: estilo, textAlign: TextAlign.center),
            ),
    );
  }
}
