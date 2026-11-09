import 'package:flutter/material.dart';

import '../../models/situacao_pedido.dart';
import '../tema.dart';

class SeloSituacao extends StatelessWidget {
  final SituacaoPedido situacao;

  const SeloSituacao(this.situacao, {super.key});

  @override
  Widget build(BuildContext context) {
    final (cor, icone) = switch (situacao) {
      SituacaoPedido.aguardando => (
        CoresDiskGas.ambar,
        Icons.hourglass_top_rounded,
      ),
      SituacaoPedido.aceito => (
        CoresDiskGas.azulEscuro,
        Icons.local_shipping_outlined,
      ),
      SituacaoPedido.entregue => (CoresDiskGas.verde, Icons.check_rounded),
      SituacaoPedido.recusado => (CoresDiskGas.vermelho, Icons.close_rounded),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 16, color: cor),
          const SizedBox(width: 4),
          Text(
            situacao.rotulo,
            style: TextStyle(
              color: cor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
