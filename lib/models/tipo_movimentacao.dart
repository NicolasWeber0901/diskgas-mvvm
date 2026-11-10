enum TipoMovimentacao {
  entrada('Entrada'),
  saida('Saída por entrega'),
  inicial('Estoque inicial');

  final String rotulo;

  const TipoMovimentacao(this.rotulo);
}
