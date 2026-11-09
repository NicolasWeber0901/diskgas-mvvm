import 'package:flutter/material.dart';

import '../../models/cliente.dart';
import '../tema.dart';
import '../widgets/formatos.dart';
import '../widgets/linha_dado.dart';

class DadosCliente extends StatelessWidget {
  final Cliente cliente;

  const DadosCliente(this.cliente, {super.key});

  @override
  Widget build(BuildContext context) {
    final endereco = cliente.endereco;
    return Column(
      children: [
        _CartaoDados(
          titulo: 'Contato',
          dados: [
            LinhaDado(
              Icons.phone_outlined,
              'Celular',
              formatarTelefone(cliente.telefone),
              estiloRotulo: EstilosDiskGas.rotulo,
            ),
            LinhaDado(
              Icons.mail_outline,
              'E-mail',
              cliente.email,
              estiloRotulo: EstilosDiskGas.rotulo,
            ),
            LinhaDado(
              Icons.badge_outlined,
              'CPF',
              mascararCpf(cliente.cpf),
              estiloRotulo: EstilosDiskGas.rotulo,
            ),
            LinhaDado(
              Icons.cake_outlined,
              'Nascimento',
              formatarDataCurta(cliente.dataNascimento),
              estiloRotulo: EstilosDiskGas.rotulo,
            ),
          ],
        ),
        _CartaoDados(
          titulo: 'Endereço de entrega',
          dados: [
            LinhaDado(
              Icons.place_outlined,
              '${endereco.bairro}, ${endereco.cidade}',
              '${endereco.rua}, ${endereco.numero}',
              estiloRotulo: EstilosDiskGas.rotulo,
            ),
          ],
        ),
      ],
    );
  }
}

class _CartaoDados extends StatelessWidget {
  final String titulo;
  final List<Widget> dados;

  const _CartaoDados({required this.titulo, required this.dados});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final dado in dados)
              Padding(padding: const EdgeInsets.only(bottom: 12), child: dado),
          ],
        ),
      ),
    );
  }
}
