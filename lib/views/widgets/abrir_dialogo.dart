import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<R?> abrirDialogo<R, V extends ChangeNotifier>(
  BuildContext context,
  V viewModel,
  Widget dialogo,
) {
  return showDialog<R>(
    context: context,
    builder: (context) =>
        ChangeNotifierProvider<V>.value(value: viewModel, child: dialogo),
  );
}
