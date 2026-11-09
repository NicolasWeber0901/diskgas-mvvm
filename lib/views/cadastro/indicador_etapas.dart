import 'package:flutter/material.dart';

import '../tema.dart';

class IndicadorEtapas extends StatelessWidget {
  final int atual;
  final int total;

  const IndicadorEtapas({required this.atual, required this.total, super.key});

  @override
  Widget build(BuildContext context) {
    final duracao = MovimentoDiskGas.duracao(context, MovimentoDiskGas.lento);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            'Passo ${atual + 1} de $total',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          spacing: 8,
          children: [
            for (var indice = 0; indice < total; indice++)
              Expanded(
                child: AnimatedContainer(
                  duration: duracao,
                  curve: MovimentoDiskGas.curva,
                  height: 8,
                  decoration: BoxDecoration(
                    color: indice <= atual
                        ? CoresDiskGas.laranjaBotao
                        : CoresDiskGas.areia,
                    borderRadius: EstilosDiskGas.raioPilula,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
