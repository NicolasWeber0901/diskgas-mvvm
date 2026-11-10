import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/movimentacao_estoque.dart';
import '../services/falhas.dart';
import '../services/produto_service.dart';

/// US18: entradas e saídas do estoque, da mais recente para a mais antiga.
class HistoricoEstoqueViewModel extends ChangeNotifier {
  final ProdutoService _produtoService;
  StreamSubscription<List<MovimentacaoEstoque>>? _inscricao;

  List<MovimentacaoEstoque> movimentacoes = [];
  String? produtoSelecionado;
  bool carregando = true;
  String? erro;

  HistoricoEstoqueViewModel(this._produtoService);

  void iniciar() {
    _inscricao = _produtoService.observarMovimentacoes().listen(
      (lista) {
        movimentacoes = [...lista]..sort((a, b) => b.data.compareTo(a.data));
        carregando = false;
        erro = null;
        notifyListeners();
      },
      onError: (Object _) {
        carregando = false;
        erro = const FalhaConexao().mensagem;
        notifyListeners();
      },
    );
  }

  List<({String id, String nome})> get produtos {
    final nomes = <String, String>{
      for (final movimentacao in movimentacoes)
        movimentacao.produtoId: movimentacao.nomeProduto,
    };
    return [
      for (final produto in nomes.entries)
        (id: produto.key, nome: produto.value),
    ]..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
  }

  List<MovimentacaoEstoque> get movimentacoesFiltradas {
    final produto = produtoSelecionado;
    if (produto == null) return movimentacoes;
    return [
      for (final movimentacao in movimentacoes)
        if (movimentacao.produtoId == produto) movimentacao,
    ];
  }

  void escolherProduto(String? produtoId) {
    produtoSelecionado = produtoId;
    notifyListeners();
  }

  @override
  void dispose() {
    _inscricao?.cancel();
    super.dispose();
  }
}
