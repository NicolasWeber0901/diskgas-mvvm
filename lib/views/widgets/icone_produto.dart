import 'package:flutter/material.dart';

import '../tema.dart';

class IconeProduto extends StatelessWidget {
  final String produtoId;
  final bool ativo;

  const IconeProduto(this.produtoId, {this.ativo = true, super.key});

  @override
  Widget build(BuildContext context) {
    final (icone, cor) = switch (produtoId) {
      'gas' => (
        Icons.local_fire_department_rounded,
        CoresDiskGas.laranjaEscuro,
      ),
      'agua' => (Icons.water_drop_rounded, CoresDiskGas.azulAgua),
      _ => (Icons.inventory_2_rounded, CoresDiskGas.cinzaQuente),
    };
    final corFinal = ativo ? cor : CoresDiskGas.cinzaQuente;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: corFinal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icone, color: corFinal, size: 26),
    );
  }
}
