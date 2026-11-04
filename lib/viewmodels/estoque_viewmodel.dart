import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/produto.dart';
import '../services/falhas.dart';
import '../services/produto_service.dart';

/// US08 e US09: cadastro e edição de produtos e entrada no estoque.
class EstoqueViewModel extends ChangeNotifier {
  final ProdutoService _produtoService;
  StreamSubscription<List<Produto>>? _inscricao;
  bool _descartado = false;

  List<Produto> produtos = [];
  bool carregando = true;
  bool salvando = false;
  String? erro;

  EstoqueViewModel(this._produtoService);

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
  }

  Future<bool> salvarProduto({
    Produto? produto,
    required String nome,
    required String preco,
    String quantidadeInicial = '0',
  }) async {
    final nomeLimpo = nome.trim();
    final valor = double.tryParse(preco.trim().replaceAll(',', '.'));
    final quantidade = int.tryParse(quantidadeInicial.trim());

    if (nomeLimpo.isEmpty) {
      return _falhar('Informe o nome do produto.');
    }
    if (valor == null || valor <= 0) {
      return _falhar('O preço deve ser maior que zero.');
    }
    if (produto == null && (quantidade == null || quantidade < 0)) {
      return _falhar('A quantidade inicial não pode ser negativa.');
    }

    return _executar(() async {
      if (produto == null) {
        await _produtoService.criar(
          Produto(
            id: '',
            nome: nomeLimpo,
            preco: valor,
            quantidadeEstoque: quantidade!,
          ),
        );
      } else {
        await _produtoService.editar(produto.id, nome: nomeLimpo, preco: valor);
      }
    });
  }

  Future<bool> registrarEntrada(Produto produto, String quantidade) async {
    final recebida = int.tryParse(quantidade.trim());
    if (recebida == null || recebida <= 0) {
      return _falhar('A quantidade recebida deve ser maior que zero.');
    }
    return _executar(
      () => _produtoService.registrarEntrada(produto.id, recebida),
    );
  }

  void limparErro() {
    if (_descartado) return;
    erro = null;
    notifyListeners();
  }

  bool _falhar(String mensagem) {
    erro = mensagem;
    notifyListeners();
    return false;
  }

  Future<bool> _executar(Future<void> Function() acao) async {
    salvando = true;
    erro = null;
    notifyListeners();
    try {
      await acao();
      return true;
    } on FalhaServico catch (e) {
      erro = e.mensagem;
      return false;
    } finally {
      salvando = false;
      if (!_descartado) notifyListeners();
    }
  }

  @override
  void dispose() {
    _descartado = true;
    _inscricao?.cancel();
    super.dispose();
  }
}
