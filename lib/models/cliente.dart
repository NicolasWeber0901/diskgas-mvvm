import 'endereco.dart';

class Cliente {
  final String id;
  final String nome;
  final String telefone;
  final String cpf;
  final DateTime dataNascimento;
  final Endereco endereco;
  final String email;

  const Cliente({
    required this.id,
    required this.nome,
    required this.telefone,
    required this.cpf,
    required this.dataNascimento,
    required this.endereco,
    required this.email,
  });

  factory Cliente.fromMap(String id, Map<String, dynamic> map) {
    return Cliente(
      id: id,
      nome: map['nome'] as String? ?? '',
      telefone: map['telefone'] as String? ?? '',
      cpf: map['cpf'] as String? ?? '',
      dataNascimento: DateTime.parse(map['dataNascimento'] as String),
      endereco: Endereco.fromMap(
        Map<String, dynamic>.from(map['endereco'] as Map? ?? {}),
      ),
      email: map['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'perfil': 'cliente',
      'nome': nome,
      'telefone': telefone,
      'cpf': cpf,
      'dataNascimento': dataNascimento.toIso8601String().substring(0, 10),
      'endereco': endereco.toMap(),
      'email': email,
    };
  }
}
