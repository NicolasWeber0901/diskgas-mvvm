class ItemPedido {
  final String produtoId;
  final String nomeProduto;
  final double precoUnitario;
  final int quantidadePedida;
  final int? quantidadeEntregue;

  const ItemPedido({
    required this.produtoId,
    required this.nomeProduto,
    required this.precoUnitario,
    required this.quantidadePedida,
    this.quantidadeEntregue,
  });

  double get subtotal => precoUnitario * quantidadePedida;

  factory ItemPedido.fromMap(Map<String, dynamic> map) {
    return ItemPedido(
      produtoId: map['produtoId'] as String? ?? '',
      nomeProduto: map['nomeProduto'] as String? ?? '',
      precoUnitario: (map['precoUnitario'] as num? ?? 0).toDouble(),
      quantidadePedida: (map['quantidadePedida'] as num? ?? 0).toInt(),
      quantidadeEntregue: (map['quantidadeEntregue'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'produtoId': produtoId,
      'nomeProduto': nomeProduto,
      'precoUnitario': precoUnitario,
      'quantidadePedida': quantidadePedida,
      if (quantidadeEntregue != null) 'quantidadeEntregue': quantidadeEntregue,
    };
  }
}
