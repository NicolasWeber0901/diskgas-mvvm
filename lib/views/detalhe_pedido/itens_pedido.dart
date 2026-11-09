import 'package:flutter/material.dart';

import '../../models/pedido.dart';
import '../tema.dart';
import '../widgets/formatos.dart';
import '../widgets/linha_item_pedido.dart';

class ItensPedido extends StatelessWidget {
  final Pedido pedido;

  const ItensPedido(this.pedido, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Itens do pedido',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final item in pedido.itens) LinhaItemPedido(item),
            const Divider(height: 24),
            Row(
              children: [
                const Text('Total', style: EstilosDiskGas.negrito),
                const Spacer(),
                Text(
                  formatarPreco(pedido.valorFinal),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: CoresDiskGas.laranjaEscuro,
                  ),
                ),
              ],
            ),
            if (pedido.valorFinal != pedido.valorTotal)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Pedido original: ${formatarPreco(pedido.valorTotal)}',
                  style: EstilosDiskGas.rotulo,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
