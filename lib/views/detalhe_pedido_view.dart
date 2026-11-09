import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../models/coordenada.dart';
import '../models/pedido.dart';
import '../models/situacao_pedido.dart';
import '../viewmodels/detalhe_pedido_viewmodel.dart';
import 'tema.dart';
import 'widgets/botao_sair.dart';
import 'widgets/aviso_destaque.dart';
import 'widgets/botoes_dialogo.dart';
import 'widgets/formatos.dart';
import 'widgets/linha_item_pedido.dart';
import 'widgets/mensagem_erro.dart';
import 'widgets/selo_situacao.dart';

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
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/admin'),
        ),
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
                _CartaoCliente(pedido),
                const SizedBox(height: 16),
                Card(
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
                            const Text(
                              'Total',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
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
                              'Pedido original: '
                              '${formatarPreco(pedido.valorTotal)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: CoresDiskGas.cinzaQuente,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _Historico(pedido),
                const SizedBox(height: 16),
                _BlocoRota(viewModel: viewModel, pedido: pedido),
                const SizedBox(height: 16),
                ..._acoes(context, viewModel, pedido),
              ],
            ),
    );
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
        const SizedBox(height: 12),
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
                    destrutivo: true,
                    acao: viewModel.recusar,
                  ),
                )
              : null,
          child: const Text('Recusar'),
        ),
      ],
      SituacaoPedido.aceito => [
        AvisoDestaque(
          icone: Icons.timer_outlined,
          titulo: 'Tempo estimado de entrega',
          texto: '${pedido.tempoEstimadoMinutos ?? 0} min',
          cor: CoresDiskGas.azulEscuro,
        ),
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
        const SizedBox(height: 12),
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
      SituacaoPedido.entregue || SituacaoPedido.recusado => [],
    };
  }
}

class _CartaoCliente extends StatelessWidget {
  final Pedido pedido;

  const _CartaoCliente(this.pedido);

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    Widget dado(IconData icone, String rotulo, String valor) => Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CoresDiskGas.laranjaBotao.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icone, size: 20, color: CoresDiskGas.laranjaEscuro),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rotulo,
                  style: textos.bodySmall?.copyWith(
                    color: CoresDiskGas.cinzaQuente,
                  ),
                ),
                Text(
                  valor,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: CoresDiskGas.laranjaBotao.withValues(
                    alpha: 0.16,
                  ),
                  foregroundColor: CoresDiskGas.laranjaEscuro,
                  child: Text(
                    pedido.clienteNome.isEmpty
                        ? '?'
                        : pedido.clienteNome[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
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
            dado(
              Icons.phone_outlined,
              'Telefone',
              formatarTelefone(pedido.clienteTelefone),
            ),
            dado(
              Icons.place_outlined,
              'Endereço de entrega',
              pedido.endereco.textoCompleto,
            ),
            dado(
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

class _Historico extends StatelessWidget {
  final Pedido pedido;

  const _Historico(this.pedido);

  @override
  Widget build(BuildContext context) {
    final etapas = <(IconData, Color, String, String?)>[
      (
        Icons.receipt_long_outlined,
        CoresDiskGas.ambar,
        'Pedido feito',
        formatarData(pedido.dataCriacao),
      ),
      if (pedido.situacao == SituacaoPedido.aceito ||
          pedido.situacao == SituacaoPedido.entregue)
        (
          Icons.local_shipping_outlined,
          CoresDiskGas.azulEscuro,
          'Aceito',
          pedido.situacao == SituacaoPedido.aceito ||
                  pedido.tempoEstimadoMinutos == null
              ? null
              : 'Tempo estimado: ${pedido.tempoEstimadoMinutos} min',
        ),
      if (pedido.situacao == SituacaoPedido.entregue)
        (
          Icons.check_circle_outline,
          CoresDiskGas.verde,
          'Entregue',
          pedido.dataEntrega == null ? null : formatarData(pedido.dataEntrega!),
        ),
      if (pedido.situacao == SituacaoPedido.recusado)
        (
          Icons.cancel_outlined,
          CoresDiskGas.vermelho,
          'Recusado',
          pedido.motivoRecusa,
        ),
    ];
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Histórico', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (var i = 0; i < etapas.length; i++)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: etapas[i].$2.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            etapas[i].$1,
                            size: 20,
                            color: etapas[i].$2,
                          ),
                        ),
                        if (i < etapas.length - 1)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: CoresDiskGas.areia,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 6,
                          bottom: i < etapas.length - 1 ? 16 : 0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              etapas[i].$3,
                              style: TextStyle(
                                color: etapas[i].$2,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (etapas[i].$4 != null)
                              Text(
                                etapas[i].$4!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
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
      final textos = Theme.of(context).textTheme;
      Widget valor(String rotulo, String texto) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rotulo,
              style: textos.bodySmall?.copyWith(
                color: CoresDiskGas.cinzaQuente,
              ),
            ),
            Text(texto, style: textos.titleLarge),
          ],
        ),
      );
      final rota = viewModel.rota;
      return Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (rota.isNotEmpty)
              _MapaRota(rota: rota, cliente: pedido.clienteNome),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: CoresDiskGas.azulAgua.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.route_rounded,
                      color: CoresDiskGas.azulEscuro,
                    ),
                  ),
                  const SizedBox(width: 16),
                  valor('Distância', '$km km'),
                  valor('Deslocamento', '${deslocamento.duracaoMinutos} min'),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return MensagemErro(viewModel.avisoRota);
  }
}

class _MapaRota extends StatefulWidget {
  final List<Coordenada> rota;
  final String cliente;

  const _MapaRota({required this.rota, required this.cliente});

  @override
  State<_MapaRota> createState() => _MapaRotaState();
}

class _MapaRotaState extends State<_MapaRota> {
  LatLngBounds _limites() {
    final latitudes = widget.rota.map((p) => p.latitude);
    final longitudes = widget.rota.map((p) => p.longitude);
    return LatLngBounds(
      southwest: LatLng(
        latitudes.reduce((a, b) => a < b ? a : b),
        longitudes.reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        latitudes.reduce((a, b) => a > b ? a : b),
        longitudes.reduce((a, b) => a > b ? a : b),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pontos = [
      for (final p in widget.rota) LatLng(p.latitude, p.longitude),
    ];
    return Semantics(
      label: 'Mapa com a rota do depósito até o cliente',
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: pontos.first, zoom: 14),
          polylines: {
            Polyline(
              polylineId: const PolylineId('rota'),
              points: pontos,
              color: CoresDiskGas.laranjaBotao,
              width: 5,
            ),
          },
          markers: {
            Marker(
              markerId: const MarkerId('deposito'),
              position: pontos.first,
              infoWindow: const InfoWindow(title: 'Depósito'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
            ),
            Marker(
              markerId: const MarkerId('cliente'),
              position: pontos.last,
              infoWindow: InfoWindow(title: widget.cliente),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange,
              ),
            ),
          },
          zoomControlsEnabled: true,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          gestureRecognizers: {
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
          onMapCreated: (controlador) {
            if (pontos.length < 2) return;
            Future<void>.delayed(const Duration(milliseconds: 300), () {
              if (!mounted) return;
              controlador
                  .animateCamera(CameraUpdate.newLatLngBounds(_limites(), 48))
                  .onError<PlatformException>((_, _) {});
            });
          },
        ),
      ),
    );
  }
}

class _DialogoTexto extends StatefulWidget {
  final String titulo;
  final String rotulo;
  final String confirmar;
  final bool numerico;
  final bool destrutivo;
  final Future<bool> Function(String texto) acao;

  const _DialogoTexto({
    required this.titulo,
    required this.rotulo,
    required this.confirmar,
    required this.numerico,
    required this.acao,
    this.destrutivo = false,
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
          ),
          if (viewModel.erro != null) MensagemErro(viewModel.erro),
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
              ),
            if (viewModel.erro != null) MensagemErro(viewModel.erro),
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
