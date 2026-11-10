import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/pedido.dart';
import '../../viewmodels/detalhe_pedido_viewmodel.dart';
import '../widgets/botoes_dialogo.dart';
import '../widgets/mensagem_erro.dart';

class DialogoTexto extends StatefulWidget {
  final String titulo;
  final String rotulo;
  final String confirmar;
  final bool numerico;
  final bool destrutivo;
  final Future<bool> Function(String texto) acao;

  const DialogoTexto({
    required this.titulo,
    required this.rotulo,
    required this.confirmar,
    required this.numerico,
    required this.acao,
    this.destrutivo = false,
    super.key,
  });

  @override
  State<DialogoTexto> createState() => _DialogoTextoState();
}

class _DialogoTextoState extends State<DialogoTexto> {
  final _texto = TextEditingController();

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    final concluido = await widget.acao(_texto.text);
    if (concluido && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DetalhePedidoViewModel>();
    return AlertDialog(
      title: Text(widget.titulo),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          TextField(
            controller: _texto,
            decoration: InputDecoration(labelText: widget.rotulo),
            keyboardType: widget.numerico
                ? TextInputType.number
                : TextInputType.multiline,
            maxLines: widget.numerico ? 1 : 3,
            minLines: 1,
            autofocus: true,
            onChanged: (_) {
              if (viewModel.erro != null) viewModel.limparErro();
            },
          ),
          MensagemErro(viewModel.erro, reservarEspaco: true),
        ],
      ),
      actions: [
        BotoesDialogo(
          confirmar: widget.confirmar,
          destrutivo: widget.destrutivo,
          aoConfirmar: viewModel.processando ? null : _confirmar,
        ),
      ],
    );
  }
}

class DialogoEntrega extends StatefulWidget {
  final Pedido pedido;

  const DialogoEntrega({required this.pedido, super.key});

  @override
  State<DialogoEntrega> createState() => _DialogoEntregaState();
}

class _DialogoEntregaState extends State<DialogoEntrega> {
  late final _quantidades = {
    for (final item in widget.pedido.itens)
      item.produtoId: TextEditingController(text: '${item.quantidadePedida}'),
  };

  @override
  void dispose() {
    for (final controlador in _quantidades.values) {
      controlador.dispose();
    }
    super.dispose();
  }

  Future<void> _confirmar(DetalhePedidoViewModel viewModel) async {
    final finalizado = await viewModel.finalizarEntrega({
      for (final entrada in _quantidades.entries)
        entrada.key: entrada.value.text,
    });
    if (finalizado) HapticFeedback.mediumImpact();
    if (finalizado && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DetalhePedidoViewModel>();
    return AlertDialog(
      title: const Text('Finalizar entrega'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            for (final item in widget.pedido.itens)
              TextField(
                controller: _quantidades[item.produtoId],
                decoration: InputDecoration(
                  labelText:
                      '${item.nomeProduto} (pedido: ${item.quantidadePedida})',
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) {
                  if (viewModel.erro != null) viewModel.limparErro();
                },
              ),
            MensagemErro(viewModel.erro, reservarEspaco: true),
          ],
        ),
      ),
      actions: [
        BotoesDialogo(
          confirmar: 'Finalizar',
          aoConfirmar: viewModel.processando
              ? null
              : () => _confirmar(viewModel),
        ),
      ],
    );
  }
}
