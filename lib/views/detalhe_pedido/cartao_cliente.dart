import 'package:flutter/material.dart';

import '../../models/pedido.dart';
import '../widgets/avatar_iniciais.dart';
import '../widgets/formatos.dart';
import '../widgets/linha_dado.dart';
import '../widgets/selo_situacao.dart';

class CartaoCliente extends StatelessWidget {
  final Pedido pedido;

  const CartaoCliente(this.pedido, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Row(
              children: [
                AvatarIniciais(pedido.clienteNome, raio: 24, tamanhoFonte: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    pedido.clienteNome,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SeloSituacao(pedido.situacao),
              ],
            ),
            LinhaDado(
              Icons.phone_outlined,
              'Celular',
              formatarTelefone(pedido.clienteTelefone),
            ),
            LinhaDado(
              Icons.place_outlined,
              'Endereço de entrega',
              pedido.endereco.textoCompleto,
            ),
            LinhaDado(
              Icons.schedule_outlined,
              'Pedido feito em',
              formatarData(pedido.dataCriacao),
            ),
          ],
        ),
      ),
    );
  }
}
