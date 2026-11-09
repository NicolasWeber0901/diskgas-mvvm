import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/pedidos_viewmodel.dart';
import 'pedidos/painel_filtros.dart';
import 'tema.dart';
import 'widgets/botao_sair.dart';
import 'widgets/cartao_pedido.dart';
import 'widgets/estado_vazio.dart';
import 'widgets/formatos.dart';
import 'widgets/mensagem_erro.dart';
import 'widgets/navegacao_admin.dart';

const _alturaMaximaDosFiltros = 0.6;

/// Tela inicial do administrador: pedidos recebidos e filtros (US10 e US17).
class PedidosView extends StatelessWidget {
  const PedidosView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PedidosViewModel>();
    final pedidos = viewModel.pedidosFiltrados;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Pedidos'),
        actions: const [BotaoSair()],
      ),
      bottomNavigationBar: const NavegacaoAdmin(0),
      body: viewModel.carregando
          ? const Center(child: CircularProgressIndicator())
          : viewModel.erro != null
          ? Center(child: MensagemErro(viewModel.erro))
          : viewModel.pedidos.isEmpty
          ? const EstadoVazio(
              icone: Icons.inbox_outlined,
              mensagem: 'Nenhum pedido recebido.',
            )
          : LayoutBuilder(
              builder: (context, limites) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: limites.maxHeight * _alturaMaximaDosFiltros,
                    ),
                    child: SingleChildScrollView(
                      child: PainelFiltros(viewModel),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            [
                              if (viewModel.filtrando) 'Filtrando',
                              pedidos.length == 1
                                  ? '1 pedido'
                                  : '${pedidos.length} pedidos',
                            ].join(' · '),
                            style: const TextStyle(
                              color: CoresDiskGas.cinzaQuente,
                            ),
                          ),
                        ),
                        if (viewModel.filtrando)
                          TextButton(
                            onPressed: viewModel.limparFiltros,
                            child: const Text('Limpar filtros'),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 16),
                      children: [
                        if (pedidos.isEmpty)
                          const EstadoVazio(
                            icone: Icons.filter_alt_off_outlined,
                            mensagem: 'Nenhum pedido com esses filtros.',
                          ),
                        for (final pedido in pedidos)
                          CartaoPedido(
                            pedido: pedido,
                            titulo: Text(
                              pedido.clienteNome,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            subtitulo: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(formatarData(pedido.dataCriacao)),
                                Text(
                                  formatarPreco(pedido.valorFinal),
                                  style: EstilosDiskGas.valorVerde,
                                ),
                              ],
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
