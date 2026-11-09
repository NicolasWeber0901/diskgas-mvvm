import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/cliente.dart';
import '../viewmodels/clientes_viewmodel.dart';
import 'tema.dart';
import 'widgets/avatar_iniciais.dart';
import 'widgets/botao_sair.dart';
import 'widgets/entrada_animada.dart';
import 'widgets/estado_vazio.dart';
import 'widgets/formatos.dart';
import 'widgets/mensagem_erro.dart';
import 'widgets/navegacao_admin.dart';
import 'widgets/troca_suave.dart';

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
      body: TrocaSuave(
        child: viewModel.carregando
            ? const Center(child: CircularProgressIndicator())
            : viewModel.erro != null
            ? Center(child: MensagemErro(viewModel.erro))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: _CampoBusca(aoBuscar: viewModel.buscar),
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
                              for (final (indice, cliente) in clientes.indexed)
                                EntradaAnimada(
                                  ordem: indice,
                                  child: _CartaoCliente(
                                    cliente: cliente,
                                    pedidos: viewModel.quantidadeDePedidos(
                                      cliente,
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

class _CampoBusca extends StatefulWidget {
  final ValueChanged<String> aoBuscar;

  const _CampoBusca({required this.aoBuscar});

  @override
  State<_CampoBusca> createState() => _CampoBuscaState();
}

class _CampoBuscaState extends State<_CampoBusca> {
  final _texto = TextEditingController();

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  void _alterar(String valor) {
    widget.aoBuscar(valor);
    setState(() {});
  }

  void _limpar() {
    _texto.clear();
    _alterar('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _texto,
      onChanged: _alterar,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Buscar pelo nome',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _texto.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpar busca',
                icon: const Icon(Icons.close_rounded),
                onPressed: _limpar,
              ),
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
