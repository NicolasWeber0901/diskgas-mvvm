import 'package:flutter/material.dart';

import '../tema.dart';

class BotoesDialogo extends StatelessWidget {
  final String confirmar;
  final VoidCallback? aoConfirmar;
  final String cancelar;
  final VoidCallback? aoCancelar;
  final bool destrutivo;

  const BotoesDialogo({
    required this.confirmar,
    required this.aoConfirmar,
    this.cancelar = 'Cancelar',
    this.aoCancelar,
    this.destrutivo = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: aoCancelar ?? () => Navigator.pop(context),
              child: Text(cancelar),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: aoConfirmar,
              style: destrutivo
                  ? FilledButton.styleFrom(
                      backgroundColor: CoresDiskGas.vermelho,
                      foregroundColor: Colors.white,
                    )
                  : null,
              child: Text(confirmar),
            ),
          ),
        ],
      ),
    );
  }
}
