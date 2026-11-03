import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/endereco.dart';
import '../models/item_pedido.dart';
import '../models/pedido.dart';
import '../models/produto.dart';
import '../models/situacao_pedido.dart';
import '../services/auth_service.dart';
import '../services/cliente_service.dart';
import '../services/falhas.dart';
import '../services/pedido_service.dart';
import '../services/produto_service.dart';

typedef ItemCarrinho = ({Produto produto, int quantidade});

/// US05 e US06, com as regras RN01 (estoque disponível) e RN02 (endereço).
class CarrinhoViewModel extends ChangeNotifier {
  final AuthService _authService;
  final ClienteService _clienteService;
  final ProdutoService _produtoService;
  final PedidoService _pedidoService;
  StreamSubscription<List<Produto>>? _inscricao;
  final Map<String, int> _quantidades = {};
  bool _descartado = false;

  List<Produto> produtos = [];
  Endereco? enderecoEntrega;
  bool carregando = true;
  bool enviando = false;
  String? erro;

  CarrinhoViewModel(
    this._authService,
    this._clienteService,
    this._produtoService,
    this._pedidoService,
  );

  void iniciar() {
    _inscricao = _produtoService.observarProdutos().listen(
      (lista) {
        produtos = lista;
        carregando = false;
        notifyListeners();
      },
      onError: (Object _) {
        carregando = false;
        erro = const FalhaConexao().mensagem;
        notifyListeners();
      },
    );
    _carregarEndereco();
  }

  Future<void> _carregarEndereco() async {
    try {
      final cliente = await _clienteService.buscar(_authService.uidAtual!);
      if (_descartado) return;
      enderecoEntrega = cliente?.endereco;
      notifyListeners();
    } on FalhaServico {
      // O endereço é conferido de novo no envio (RN02).
    }
  }

  List<ItemCarrinho> get itens => [
    for (final produto in produtos)
      if (_quantidades.containsKey(produto.id))
        (produto: produto, quantidade: _quantidades[produto.id]!),
  ];

  int quantidadeDe(Produto produto) => _quantidades[produto.id] ?? 0;

  double get valorTotal => itens.fold(
    0,
    (total, item) => total + item.produto.preco * item.quantidade,
  );

  bool alterarQuantidade(Produto produto, int quantidade) {
    // RN01: a quantidade não pode passar do estoque disponível.
    if (quantidade > produto.quantidadeEstoque) {
      erro = produto.quantidadeEstoque == 0
          ? '${produto.nome} está indisponível.'
          : 'Há apenas ${produto.quantidadeEstoque} de ${produto.nome} '
                'em estoque.';
      notifyListeners();
      return false;
    }
    if (quantidade <= 0) {
      _quantidades.remove(produto.id);
    } else {
      _quantidades[produto.id] = quantidade;
    }
    erro = null;
    notifyListeners();
    return true;
  }

  Future<String?> enviarPedido() async {
    final itensDoPedido = itens;
    if (itensDoPedido.isEmpty) {
      erro = 'O carrinho está vazio.';
      notifyListeners();
      return null;
    }

    enviando = true;
    erro = null;
    notifyListeners();
    try {
      final uid = _authService.uidAtual!;
      final cliente = await _clienteService.buscar(uid);

      // RN02: o pedido vai para o endereço cadastrado, que precisa estar
      // completo.
      final endereco = cliente?.endereco;
      if (cliente == null ||
          endereco!.rua.trim().isEmpty ||
          endereco.numero.trim().isEmpty ||
          endereco.bairro.trim().isEmpty ||
          endereco.cidade.trim().isEmpty) {
        erro = 'Complete o seu endereço no cadastro antes de fazer o pedido.';
        return null;
      }

      // RN01: confere de novo, porque o estoque pode ter mudado.
      final estoqueAtual = {
        for (final produto in await _produtoService.buscarProdutos())
          produto.id: produto,
      };
      final itensPedido = <ItemPedido>[];
      for (final item in itensDoPedido) {
        final atual = estoqueAtual[item.produto.id];
        if (atual == null || item.quantidade > atual.quantidadeEstoque) {
          erro =
              'O estoque de ${item.produto.nome} mudou: há apenas '
              '${atual?.quantidadeEstoque ?? 0}.';
          return null;
        }
        itensPedido.add(
          ItemPedido(
            produtoId: atual.id,
            nomeProduto: atual.nome,
            precoUnitario: atual.preco,
            quantidadePedida: item.quantidade,
          ),
        );
      }

      final id = await _pedidoService.criar(
        Pedido(
          id: '',
          clienteId: uid,
          clienteNome: cliente.nome,
          clienteTelefone: cliente.telefone,
          endereco: endereco,
          itens: itensPedido,
          situacao: SituacaoPedido.aguardando,
          dataCriacao: DateTime.now(),
        ),
      );
      _quantidades.clear();
      return id;
    } on FalhaServico catch (e) {
      erro = e.mensagem;
      return null;
    } finally {
      enviando = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _descartado = true;
    _inscricao?.cancel();
    super.dispose();
  }
}
