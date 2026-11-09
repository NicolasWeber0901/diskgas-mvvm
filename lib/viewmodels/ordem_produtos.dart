import '../models/produto.dart';
import '../services/produto_service.dart';

int _posicao(Produto produto) {
  final indice = ProdutoService.produtosPadrao.indexWhere(
    (padrao) => padrao.id == produto.id,
  );
  return indice == -1 ? ProdutoService.produtosPadrao.length : indice;
}

List<Produto> comProdutosPadraoPrimeiro(List<Produto> produtos) {
  return [...produtos]..sort((a, b) => _posicao(a).compareTo(_posicao(b)));
}
