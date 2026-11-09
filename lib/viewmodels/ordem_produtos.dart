import '../models/produto.dart';
import '../services/produto_service.dart';

int _posicao(Produto produto) {
  final indice = ProdutoService.produtosFixos.indexWhere(
    (padrao) => padrao.id == produto.id,
  );
  return indice == -1 ? ProdutoService.produtosFixos.length : indice;
}

List<Produto> comProdutosFixosPrimeiro(List<Produto> produtos) {
  return [...produtos]..sort((a, b) => _posicao(a).compareTo(_posicao(b)));
}
