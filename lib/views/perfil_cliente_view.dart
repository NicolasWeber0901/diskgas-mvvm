import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/cliente.dart';
import '../viewmodels/perfil_cliente_viewmodel.dart';
import 'tema.dart';
import 'widgets/botao_sair.dart';
import 'widgets/estado_vazio.dart';
import 'widgets/formatos.dart';
import 'widgets/mensagem_erro.dart';
import 'widgets/selo_situacao.dart';

/// Perfil do cliente com o histórico de pedidos (US16).
class PerfilClienteView extends StatelessWidget {
  const PerfilClienteView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PerfilClienteViewModel>();
    final cliente = viewModel.cliente;
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/admin/clientes'),
        ),
        title: const Text('Cliente'),
        actions: const [BotaoSair()],
      ),
      body: viewModel.carregando
          ? const Center(child: CircularProgressIndicator())
          : cliente == null
          ? Center(
              child: viewModel.erro != null
                  ? MensagemErro(viewModel.erro)
                  : const Text('Cliente não encontrado.'),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Cabecalho(cliente),
                const SizedBox(height: 16),
                _Resumo(viewModel),
                const SizedBox(height: 16),
                _Dados(cliente),
                const SizedBox(height: 24),
                Text('Histórico de pedidos', style: textos.titleMedium),
                const SizedBox(height: 8),
                if (viewModel.pedidos.isEmpty)
                  const EstadoVazio(
                    icone: Icons.receipt_long_outlined,
                    mensagem: 'Este cliente ainda não fez pedidos.',
                  ),
                for (final pedido in viewModel.pedidos)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      title: Text(
                        formatarPreco(pedido.valorFinal),
                        style: textos.titleMedium?.copyWith(
                          color: CoresDiskGas.verde,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(
                        '${formatarData(pedido.dataCriacao)}\n'
                        '${pedido.itens.map((i) => '${i.quantidadePedida}x ${i.nomeProduto}').join(', ')}',
                      ),
                      trailing: SeloSituacao(pedido.situacao),
                      onTap: () => context.push('/admin/pedidos/${pedido.id}'),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  final Cliente cliente;

  const _Cabecalho(this.cliente);

  @override
  Widget build(BuildContext context) {
    final iniciais = cliente.nome
        .split(' ')
        .where((parte) => parte.isNotEmpty)
        .take(2)
        .map((parte) => parte[0].toUpperCase())
        .join();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: CoresDiskGas.laranjaBotao.withValues(
                alpha: 0.16,
              ),
              foregroundColor: CoresDiskGas.laranjaEscuro,
              child: Text(
                iniciais.isEmpty ? '?' : iniciais,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
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

class _Dado extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String valor;

  const _Dado(this.icone, this.rotulo, this.valor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
                  style: const TextStyle(
                    fontSize: 14,
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
  }
}

class _Dados extends StatelessWidget {
  final Cliente cliente;

  const _Dados(this.cliente);

  @override
  Widget build(BuildContext context) {
    final nascimento = cliente.dataNascimento;
    final textos = Theme.of(context).textTheme;
    Widget cartao(String titulo, List<Widget> filhos) => Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: textos.titleMedium),
            const SizedBox(height: 12),
            ...filhos,
          ],
        ),
      ),
    );
    return Column(
      children: [
        cartao('Contato', [
          _Dado(
            Icons.phone_outlined,
            'Telefone',
            formatarTelefone(cliente.telefone),
          ),
          _Dado(Icons.mail_outline, 'E-mail', cliente.email),
          _Dado(Icons.badge_outlined, 'CPF', mascararCpf(cliente.cpf)),
          _Dado(
            Icons.cake_outlined,
            'Nascimento',
            '${nascimento.day.toString().padLeft(2, '0')}/'
                '${nascimento.month.toString().padLeft(2, '0')}/'
                '${nascimento.year}',
          ),
        ]),
        cartao('Endereço de entrega', [
          _Dado(
            Icons.place_outlined,
            '${cliente.endereco.bairro}, ${cliente.endereco.cidade}',
            '${cliente.endereco.rua}, ${cliente.endereco.numero}',
          ),
        ]),
      ],
    );
  }
}

class _Resumo extends StatelessWidget {
  final PerfilClienteViewModel viewModel;

  const _Resumo(this.viewModel);

  @override
  Widget build(BuildContext context) {
    final ultimo = viewModel.ultimoPedido;
    Widget bloco(IconData icone, String rotulo, String valor, Color cor) =>
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: CoresDiskGas.areia),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icone, color: cor),
                const SizedBox(height: 8),
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: cor == CoresDiskGas.laranjaEscuro
                        ? cor
                        : CoresDiskGas.carvao,
                  ),
                ),
                Text(
                  rotulo,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CoresDiskGas.cinzaQuente,
                  ),
                ),
              ],
            ),
          ),
        );
    return Column(
      children: [
        Row(
          children: [
            bloco(
              Icons.receipt_long_outlined,
              'Pedidos',
              '${viewModel.totalDePedidos}',
              CoresDiskGas.azulEscuro,
            ),
            const SizedBox(width: 12),
            bloco(
              Icons.check_circle_outline,
              'Entregues',
              '${viewModel.pedidosEntregues}',
              CoresDiskGas.verde,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            bloco(
              Icons.payments_outlined,
              'Total gasto',
              formatarPreco(viewModel.totalGasto),
              CoresDiskGas.laranjaEscuro,
            ),
            const SizedBox(width: 12),
            bloco(
              Icons.event_outlined,
              'Último pedido',
              ultimo == null ? '-' : formatarData(ultimo).substring(0, 10),
              CoresDiskGas.ambar,
            ),
          ],
        ),
      ],
    );
  }
}
