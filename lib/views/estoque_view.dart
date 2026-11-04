import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/produto.dart';
import '../viewmodels/estoque_viewmodel.dart';
import 'widgets/botao_sair.dart';
import 'widgets/formatos.dart';
import 'widgets/mensagem_erro.dart';

/// Tela de estoque do administrador (US08 e US09).
class EstoqueView extends StatelessWidget {
  const EstoqueView({super.key});

  Future<void> _abrirDialogo(
    BuildContext context,
    EstoqueViewModel viewModel,
    Widget dialogo,
  ) async {
    viewModel.limparErro();
    final mensagem = await showDialog<String>(
      context: context,
      builder: (context) =>
          ChangeNotifierProvider.value(value: viewModel, child: dialogo),
    );
    viewModel.limparErro();
    if (mensagem != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensagem)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EstoqueViewModel>();
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/admin')),
        title: const Text('Estoque'),
        actions: const [BotaoSair()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _abrirDialogo(context, viewModel, const _DialogoProduto()),
        icon: const Icon(Icons.add),
        label: const Text('Novo produto'),
      ),
      body: viewModel.carregando
          ? const Center(child: CircularProgressIndicator())
          : viewModel.produtos.isEmpty
          ? Center(
              child: viewModel.erro != null
                  ? MensagemErro(viewModel.erro)
                  : const Text('Nenhum produto cadastrado.'),
            )
          : ListView(
              children: [
                for (final produto in viewModel.produtos)
                  ListTile(
                    title: Text(produto.nome),
                    subtitle: Text(
                      '${formatarPreco(produto.preco)} · '
                      'Estoque: ${produto.quantidadeEstoque}',
                    ),
                    onTap: () => _abrirDialogo(
                      context,
                      viewModel,
                      _DialogoProduto(produto: produto),
                    ),
                    trailing: IconButton(
                      tooltip: 'Registrar entrada',
                      icon: const Icon(Icons.add_box_outlined),
                      onPressed: () => _abrirDialogo(
                        context,
                        viewModel,
                        _DialogoEntrada(produto: produto),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _DialogoProduto extends StatefulWidget {
  final Produto? produto;

  const _DialogoProduto({this.produto});

  @override
  State<_DialogoProduto> createState() => _DialogoProdutoState();
}

class _DialogoProdutoState extends State<_DialogoProduto> {
  late final _nome = TextEditingController(text: widget.produto?.nome);
  late final _preco = TextEditingController(
    text: widget.produto?.preco.toStringAsFixed(2).replaceAll('.', ','),
  );
  final _quantidade = TextEditingController(text: '0');

  @override
  void dispose() {
    _nome.dispose();
    _preco.dispose();
    _quantidade.dispose();
    super.dispose();
  }

  Future<void> _salvar(EstoqueViewModel viewModel) async {
    final salvo = await viewModel.salvarProduto(
      produto: widget.produto,
      nome: _nome.text,
      preco: _preco.text,
      quantidadeInicial: _quantidade.text,
    );
    if (salvo && mounted) {
      Navigator.pop(context, '${_nome.text.trim()} salvo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EstoqueViewModel>();
    final novo = widget.produto == null;
    return AlertDialog(
      title: Text(novo ? 'Novo produto' : 'Editar produto'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nome,
            decoration: const InputDecoration(labelText: 'Nome'),
          ),
          TextField(
            controller: _preco,
            decoration: const InputDecoration(labelText: 'Preço (R\$)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          if (novo)
            TextField(
              controller: _quantidade,
              decoration: const InputDecoration(
                labelText: 'Quantidade inicial',
              ),
              keyboardType: TextInputType.number,
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
          onPressed: viewModel.salvando ? null : () => _salvar(viewModel),
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

class _DialogoEntrada extends StatefulWidget {
  final Produto produto;

  const _DialogoEntrada({required this.produto});

  @override
  State<_DialogoEntrada> createState() => _DialogoEntradaState();
}

class _DialogoEntradaState extends State<_DialogoEntrada> {
  final _quantidade = TextEditingController();

  @override
  void dispose() {
    _quantidade.dispose();
    super.dispose();
  }

  Future<void> _salvar(EstoqueViewModel viewModel) async {
    final registrada = await viewModel.registrarEntrada(
      widget.produto,
      _quantidade.text,
    );
    if (registrada && mounted) {
      final saldo =
          widget.produto.quantidadeEstoque + int.parse(_quantidade.text.trim());
      Navigator.pop(context, 'Novo saldo de ${widget.produto.nome}: $saldo');
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EstoqueViewModel>();
    return AlertDialog(
      title: Text('Entrada de ${widget.produto.nome}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Estoque atual: ${widget.produto.quantidadeEstoque}'),
          TextField(
            controller: _quantidade,
            decoration: const InputDecoration(labelText: 'Quantidade recebida'),
            keyboardType: TextInputType.number,
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
          onPressed: viewModel.salvando ? null : () => _salvar(viewModel),
          child: const Text('Registrar'),
        ),
      ],
    );
  }
}
