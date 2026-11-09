import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/produto.dart';
import '../viewmodels/estoque_viewmodel.dart';
import 'tema.dart';
import 'widgets/abrir_dialogo.dart';
import 'widgets/botao_sair.dart';
import 'widgets/botoes_dialogo.dart';
import 'widgets/estado_vazio.dart';
import 'widgets/formatos.dart';
import 'widgets/icone_produto.dart';
import 'widgets/mensagem_erro.dart';
import 'widgets/navegacao_admin.dart';

/// Tela de estoque do administrador (US08 e US09).
class EstoqueView extends StatelessWidget {
  const EstoqueView({super.key});

  Future<void> _abrirDialogo(
    BuildContext context,
    EstoqueViewModel viewModel,
    Widget dialogo,
  ) async {
    viewModel.limparErro();
    final mensagem = await abrirDialogo<String, EstoqueViewModel>(
      context,
      viewModel,
      dialogo,
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
        automaticallyImplyLeading: false,
        title: const Text('Estoque'),
        actions: const [BotaoSair()],
      ),
      bottomNavigationBar: const NavegacaoAdmin(2),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _abrirDialogo(context, viewModel, const _DialogoProduto()),
        icon: const Icon(Icons.add),
        label: const Text('Novo produto'),
      ),
      body: viewModel.carregando
          ? const Center(child: CircularProgressIndicator())
          : viewModel.produtos.isEmpty
          ? viewModel.erro != null
                ? Center(child: MensagemErro(viewModel.erro))
                : const EstadoVazio(
                    icone: Icons.inventory_2_outlined,
                    mensagem: 'Nenhum produto cadastrado.',
                  )
          : ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 96),
              children: [
                for (final produto in viewModel.produtos)
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      leading: IconeProduto(
                        produto.id,
                        ativo: produto.quantidadeEstoque > 0,
                      ),
                      title: Text(
                        produto.nome,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${formatarPreco(produto.preco)} · '
                            'Estoque: ${produto.quantidadeEstoque}',
                          ),
                          if (produto.quantidadeEstoque < _estoqueBaixo)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: _AvisoEstoque(produto.quantidadeEstoque),
                            ),
                        ],
                      ),
                      onTap: () => _abrirDialogo(
                        context,
                        viewModel,
                        _DialogoProduto(produto: produto),
                      ),
                      trailing: IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: CoresDiskGas.laranjaBotao,
                          foregroundColor: Colors.white,
                        ),
                        tooltip: 'Registrar entrada',
                        icon: const Icon(Icons.add_rounded),
                        onPressed: () => _abrirDialogo(
                          context,
                          viewModel,
                          _DialogoEntrada(produto: produto),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

const _estoqueBaixo = 5;

class _AvisoEstoque extends StatelessWidget {
  final int quantidade;

  const _AvisoEstoque(this.quantidade);

  @override
  Widget build(BuildContext context) {
    final semEstoque = quantidade == 0;
    final cor = semEstoque ? CoresDiskGas.vermelho : CoresDiskGas.ambar;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          semEstoque ? Icons.block_rounded : Icons.warning_amber_rounded,
          size: 16,
          color: cor,
        ),
        const SizedBox(width: 4),
        Text(
          semEstoque ? 'Sem estoque' : 'Estoque baixo',
          style: TextStyle(
            color: cor,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
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
          if (viewModel.erro != null) MensagemErro(viewModel.erro),
        ],
      ),
      actions: [
        BotoesDialogo(
          confirmar: 'Salvar',
          aoConfirmar: viewModel.salvando ? null : () => _salvar(viewModel),
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
      Navigator.pop(context, 'Novo saldo de ${widget.produto.nome}: $saldo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EstoqueViewModel>();
    return AlertDialog(
      title: Text('Entrada de ${widget.produto.nome}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Text(
            'Estoque atual: ${widget.produto.quantidadeEstoque}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          TextField(
            controller: _quantidade,
            decoration: const InputDecoration(labelText: 'Quantidade recebida'),
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
          if (viewModel.erro != null) MensagemErro(viewModel.erro),
        ],
      ),
      actions: [
        BotoesDialogo(
          confirmar: 'Registrar',
          aoConfirmar: viewModel.salvando ? null : () => _salvar(viewModel),
        ),
      ],
    );
  }
}
