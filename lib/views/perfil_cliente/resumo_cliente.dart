import 'package:flutter/material.dart';

import '../../viewmodels/perfil_cliente_viewmodel.dart';
import '../tema.dart';
import '../widgets/formatos.dart';

class ResumoCliente extends StatelessWidget {
  final PerfilClienteViewModel viewModel;

  const ResumoCliente(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    final ultimo = viewModel.ultimoPedido;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _BlocoResumo(
                icone: Icons.receipt_long_outlined,
                rotulo: 'Pedidos',
                valor: '${viewModel.totalDePedidos}',
                corIcone: CoresDiskGas.azulEscuro,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BlocoResumo(
                icone: Icons.check_circle_outline,
                rotulo: 'Entregues',
                valor: '${viewModel.pedidosEntregues}',
                corIcone: CoresDiskGas.verde,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _BlocoResumo(
                icone: Icons.payments_outlined,
                rotulo: 'Total gasto',
                valor: formatarPreco(viewModel.totalGasto),
                corIcone: CoresDiskGas.laranjaEscuro,
                corValor: CoresDiskGas.laranjaEscuro,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BlocoResumo(
                icone: Icons.event_outlined,
                rotulo: 'Último pedido',
                valor: ultimo == null ? '-' : formatarDataCurta(ultimo),
                corIcone: CoresDiskGas.ambar,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BlocoResumo extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String valor;
  final Color corIcone;
  final Color corValor;

  const _BlocoResumo({
    required this.icone,
    required this.rotulo,
    required this.valor,
    required this.corIcone,
    this.corValor = CoresDiskGas.carvao,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CoresDiskGas.areia),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: corIcone),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: corValor,
            ),
          ),
          Text(rotulo, style: EstilosDiskGas.rotulo),
        ],
      ),
    );
  }
}
