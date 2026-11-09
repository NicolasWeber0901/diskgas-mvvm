import 'package:flutter/material.dart';

import '../../models/cliente.dart';
import '../tema.dart';
import '../widgets/avatar_iniciais.dart';

class CabecalhoCliente extends StatelessWidget {
  final Cliente cliente;

  const CabecalhoCliente(this.cliente, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            AvatarIniciais(cliente.nome, raio: 32, tamanhoFonte: 24, letras: 2),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cliente.nome,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Cliente de ${cliente.endereco.cidade}',
                    style: const TextStyle(color: CoresDiskGas.cinzaQuente),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
