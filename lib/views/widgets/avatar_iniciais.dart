import 'package:flutter/material.dart';

import '../tema.dart';

class AvatarIniciais extends StatelessWidget {
  final String nome;
  final double raio;
  final double tamanhoFonte;
  final int letras;

  const AvatarIniciais(
    this.nome, {
    this.raio = 20,
    this.tamanhoFonte = 16,
    this.letras = 1,
    super.key,
  });

  String get _iniciais {
    final iniciais = nome
        .split(' ')
        .where((parte) => parte.isNotEmpty)
        .take(letras)
        .map((parte) => parte[0].toUpperCase())
        .join();
    return iniciais.isEmpty ? '?' : iniciais;
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: raio,
      backgroundColor: CoresDiskGas.laranjaBotao.withValues(alpha: 0.16),
      foregroundColor: CoresDiskGas.laranjaEscuro,
      child: Text(
        _iniciais,
        style: TextStyle(fontSize: tamanhoFonte, fontWeight: FontWeight.w800),
      ),
    );
  }
}
