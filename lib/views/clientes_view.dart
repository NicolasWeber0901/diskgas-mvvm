import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/cliente.dart';
import '../viewmodels/clientes_viewmodel.dart';
import 'tema.dart';
import 'widgets/avatar_iniciais.dart';
import 'widgets/botao_sair.dart';
import 'widgets/estado_vazio.dart';
import 'widgets/formatos.dart';
import 'widgets/mensagem_erro.dart';
import 'widgets/navegacao_admin.dart';

/// Lista de clientes do administrador (US16).
class ClientesView extends StatelessWidget {
  const ClientesView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ClientesViewModel>();
    final clientes = viewModel.clientesFiltrados;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Clientes'),
        actions: const [BotaoSair()],
      ),
      bottomNavigationBar: const NavegacaoAdmin(1),
      body: viewModel.carregando
          ? const Center(child: CircularProgressIndicator())
          : viewModel.erro != null
          ? Center(child: MensagemErro(viewModel.erro))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: TextField(
                    onChanged: viewModel.buscar,
                    decoration: const InputDecoration(
                      hintText: 'Buscar pelo nome',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: clientes.isEmpty
                      ? EstadoVazio(
                          icone: Icons.people_outline,
                          mensagem: viewModel.clientes.isEmpty
                              ? 'Nenhum cliente cadastrado.'
                              : 'Nenhum cliente com esse nome.',
                        )
                      : ListView(
                          padding: const EdgeInsets.only(bottom: 16),
                          children: [
                            for (final cliente in clientes)
                              _CartaoCliente(
                                cliente: cliente,
                                pedidos: viewModel.quantidadeDePedidos(cliente),
                              ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }
}

class _CartaoCliente extends StatelessWidget {
  final Cliente cliente;
  final int pedidos;

  const _CartaoCliente({required this.cliente, required this.pedidos});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: AvatarIniciais(cliente.nome),
        title: Text(
          cliente.nome,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          '${formatarTelefone(cliente.telefone)}\n${cliente.endereco.cidade}',
        ),
        trailing: _Contador(pedidos),
        onTap: () => context.push('/admin/clientes/${cliente.id}'),
      ),
    );
  }
}

class _Contador extends StatelessWidget {
  final int quantidade;

  const _Contador(this.quantidade);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$quantidade', style: Theme.of(context).textTheme.titleLarge),
        Text(
          quantidade == 1 ? 'pedido' : 'pedidos',
          style: EstilosDiskGas.rotulo,
        ),
      ],
    );
  }
}
