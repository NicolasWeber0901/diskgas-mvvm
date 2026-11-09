import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/pedido.dart';
import 'selo_situacao.dart';

class CartaoPedido extends StatelessWidget {
  final Pedido pedido;
  final Widget titulo;
  final Widget subtitulo;
  final EdgeInsetsGeometry? margem;

  const CartaoPedido({
    required this.pedido,
    required this.titulo,
    required this.subtitulo,
    this.margem,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margem,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: titulo,
        subtitle: subtitulo,
        trailing: SeloSituacao(pedido.situacao),
        onTap: () => context.push('/admin/pedidos/${pedido.id}'),
      ),
    );
  }
}
