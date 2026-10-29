class Administrador {
  final String id;
  final String nome;
  final String email;

  const Administrador({
    required this.id,
    required this.nome,
    required this.email,
  });

  factory Administrador.fromMap(String id, Map<String, dynamic> map) {
    return Administrador(
      id: id,
      nome: map['nome'] as String? ?? '',
      email: map['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'perfil': 'administrador', 'nome': nome, 'email': email};
  }
}
