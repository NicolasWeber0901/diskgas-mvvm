enum SituacaoPedido {
  aguardando('Aguardando'),
  aceito('Aceito'),
  entregue('Entregue'),
  recusado('Recusado');

  final String rotulo;

  const SituacaoPedido(this.rotulo);
}
