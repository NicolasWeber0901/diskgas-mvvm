import 'package:flutter/material.dart';

import '../tema.dart';

class LinhaDado extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String valor;
  final TextStyle? estiloRotulo;

  const LinhaDado(
    this.icone,
    this.rotulo,
    this.valor, {
    this.estiloRotulo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: CoresDiskGas.laranjaBotao.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icone, size: 20, color: CoresDiskGas.laranjaEscuro),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rotulo,
                style:
                    estiloRotulo ??
                    Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: CoresDiskGas.cinzaQuente),
              ),
              Text(valor, style: EstilosDiskGas.negrito),
            ],
          ),
        ),
      ],
    );
  }
}
