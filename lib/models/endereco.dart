class Endereco {
  final String rua;
  final String numero;
  final String bairro;
  final String cidade;

  const Endereco({
    required this.rua,
    required this.numero,
    required this.bairro,
    required this.cidade,
  });

  String get textoCompleto => '$rua, $numero - $bairro, $cidade';

  factory Endereco.fromMap(Map<String, dynamic> map) {
    return Endereco(
      rua: map['rua'] as String? ?? '',
      numero: map['numero'] as String? ?? '',
      bairro: map['bairro'] as String? ?? '',
      cidade: map['cidade'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'rua': rua, 'numero': numero, 'bairro': bairro, 'cidade': cidade};
  }
}
