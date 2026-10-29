class Produto {
  final String id;
  final String nome;
  final double preco;
  final int quantidadeEstoque;

  const Produto({
    required this.id,
    required this.nome,
    required this.preco,
    required this.quantidadeEstoque,
  });

  factory Produto.fromMap(String id, Map<String, dynamic> map) {
    return Produto(
      id: id,
      nome: map['nome'] as String? ?? '',
      preco: (map['preco'] as num? ?? 0).toDouble(),
      quantidadeEstoque: (map['quantidadeEstoque'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'preco': preco,
      'quantidadeEstoque': quantidadeEstoque,
    };
  }
}
