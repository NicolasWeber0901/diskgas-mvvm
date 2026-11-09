import 'package:flutter/material.dart';

import '../../models/item_pedido.dart';
import '../tema.dart';
import 'formatos.dart';
import 'icone_produto.dart';

class LinhaItemPedido extends StatelessWidget {
  final ItemPedido item;

  const LinhaItemPedido(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    final entregue = item.quantidadeEntregue;
    final diferente = entregue != null && entregue != item.quantidadePedida;
    final corEntrega = (entregue ?? 0) > item.quantidadePedida
        ? CoresDiskGas.ambar
        : CoresDiskGas.verde;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          IconeProduto(item.produtoId),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${item.quantidadePedida}x ',
                        style: const TextStyle(
                          color: CoresDiskGas.laranjaEscuro,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text: item.nomeProduto,
                        style: EstilosDiskGas.negrito,
                      ),
                    ],
                  ),
                ),
                if (diferente)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: corEntrega.withValues(alpha: 0.12),
                      borderRadius: EstilosDiskGas.raioPilula,
                    ),
                    child: Text(
                      'entregue: $entregue',
                      style: TextStyle(
                        fontSize: 14,
                        color: corEntrega,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(formatarPreco(item.valorFinal), style: EstilosDiskGas.negrito),
        ],
      ),
    );
  }
}
