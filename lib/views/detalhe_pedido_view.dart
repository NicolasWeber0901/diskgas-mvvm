import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/item_pedido.dart';
import '../models/pedido.dart';
import '../models/situacao_pedido.dart';
import '../viewmodels/detalhe_pedido_viewmodel.dart';
import 'widgets/botao_sair.dart';
import 'widgets/formatos.dart';
import 'widgets/mensagem_erro.dart';

/// Detalhe do pedido para o administrador (US10 a US15).
class DetalhePedidoView extends StatelessWidget {
  const DetalhePedidoView({super.key});

  Future<void> _abrirDialogo(
    BuildContext context,
    DetalhePedidoViewModel viewModel,
    Widget dialogo,
  ) async {
    viewModel.limparErro();
    await showDialog<void>(
      context: context,
      builder: (context) =>
          ChangeNotifierProvider.value(value: viewModel, child: dialogo),
    );
    viewModel.limparErro();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DetalhePedidoViewModel>();
    final pedido = viewModel.pedido;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/admin')),
        title: const Text('Pedido'),
        actions: const [BotaoSair()],
      ),
      body: viewModel.carregando
          ? const Center(child: CircularProgressIndicator())
          : pedido == null
          ? Center(
              child: viewModel.erro != null
                  ? MensagemErro(viewModel.erro)
                  : const Text('Pedido não encontrado.'),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  pedido.clienteNome,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text('Telefone: ${pedido.clienteTelefone}'),
                Text('Endereço: ${pedido.endereco.textoCompleto}'),
                Text('Feito em ${formatarData(pedido.dataCriacao)}'),
                const SizedBox(height: 16),
                for (final item in pedido.itens) Text(_textoItem(item)),
                const SizedBox(height: 8),
                Text(
                  'Total: ${formatarPreco(pedido.valorTotal)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text('Situação: ${pedido.situacao.rotulo}'),
                const SizedBox(height: 8),
                _BlocoRota(viewModel: viewModel, pedido: pedido),
                const SizedBox(height: 16),
                ..._acoes(context, viewModel, pedido),
              ],
            ),
    );
  }

  String _textoItem(ItemPedido item) {
    final texto = '${item.quantidadePedida}x ${item.nomeProduto}';
    final entregue = item.quantidadeEntregue;
    if (entregue == null) return texto;
    return '$texto (entregue: $entregue)';
  }

  List<Widget> _acoes(
    BuildContext context,
    DetalhePedidoViewModel viewModel,
    Pedido pedido,
  ) {
    final livre = !viewModel.processando;
    return switch (pedido.situacao) {
      SituacaoPedido.aguardando => [
        FilledButton(
          onPressed: livre
              ? () => _abrirDialogo(
                  context,
                  viewModel,
                  _DialogoTexto(
                    titulo: 'Aceitar pedido',
                    rotulo: 'Tempo estimado (min)',
                    confirmar: 'Aceitar',
                    numerico: true,
                    acao: viewModel.aceitar,
                  ),
                )
              : null,
          child: const Text('Aceitar'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: livre
              ? () => _abrirDialogo(
                  context,
                  viewModel,
                  _DialogoTexto(
                    titulo: 'Recusar pedido',
                    rotulo: 'Motivo da recusa',
                    confirmar: 'Recusar',
                    numerico: false,
                    acao: viewModel.recusar,
                  ),
                )
              : null,
          child: const Text('Recusar'),
        ),
      ],
      SituacaoPedido.aceito => [
        Text('Tempo estimado: ${pedido.tempoEstimadoMinutos ?? 0} min'),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: livre
              ? () => _abrirDialogo(
                  context,
                  viewModel,
                  _DialogoEntrega(pedido: pedido),
                )
              : null,
          child: const Text('Finalizar entrega'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: livre
              ? () => _abrirDialogo(
                  context,
                  viewModel,
                  _DialogoTexto(
                    titulo: 'Ampliar tempo',
                    rotulo: 'Minutos a mais',
                    confirmar: 'Ampliar',
                    numerico: true,
                    acao: viewModel.ampliarTempo,
                  ),
                )
              : null,
          child: const Text('Ampliar tempo'),
        ),
      ],
      SituacaoPedido.entregue => [
        if (pedido.dataEntrega != null)
          Text('Entregue em ${formatarData(pedido.dataEntrega!)}'),
      ],
      SituacaoPedido.recusado => [
        Text('Motivo da recusa: ${pedido.motivoRecusa ?? ''}'),
      ],
    };
  }
}

class _BlocoRota extends StatelessWidget {
  final DetalhePedidoViewModel viewModel;
  final Pedido pedido;

  const _BlocoRota({required this.viewModel, required this.pedido});

  @override
  Widget build(BuildContext context) {
    final deslocamento = pedido.deslocamento;
    if (viewModel.calculandoRota) {
      return const Row(
        children: [
          SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('Calculando a distância...'),
        ],
      );
    }
    if (deslocamento != null) {
      final km = deslocamento.distanciaKm
          .toStringAsFixed(1)
          .replaceAll('.', ',');
      return Text(
        'Distância: $km km · Deslocamento: ${deslocamento.duracaoMinutos} min',
      );
    }
    return MensagemErro(viewModel.avisoRota);
  }
}

class _DialogoTexto extends StatefulWidget {
  final String titulo;
  final String rotulo;
  final String confirmar;
  final bool numerico;
  final Future<bool> Function(String texto) acao;

  const _DialogoTexto({
    required this.titulo,
    required this.rotulo,
    required this.confirmar,
    required this.numerico,
    required this.acao,
  });

  @override
  State<_DialogoTexto> createState() => _DialogoTextoState();
}

class _DialogoTextoState extends State<_DialogoTexto> {
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
          ),
          MensagemErro(viewModel.erro),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: viewModel.processando ? null : _confirmar,
          child: Text(widget.confirmar),
        ),
      ],
    );
  }
}

class _DialogoEntrega extends StatefulWidget {
  final Pedido pedido;

  const _DialogoEntrega({required this.pedido});

  @override
  State<_DialogoEntrega> createState() => _DialogoEntregaState();
}

class _DialogoEntregaState extends State<_DialogoEntrega> {
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
          children: [
            for (final item in widget.pedido.itens)
              TextField(
                controller: _quantidades[item.produtoId],
                decoration: InputDecoration(
                  labelText:
                      '${item.nomeProduto} (pedido: ${item.quantidadePedida})',
                ),
                keyboardType: TextInputType.number,
              ),
            MensagemErro(viewModel.erro),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: viewModel.processando ? null : () => _confirmar(viewModel),
          child: const Text('Finalizar'),
        ),
      ],
    );
  }
}
