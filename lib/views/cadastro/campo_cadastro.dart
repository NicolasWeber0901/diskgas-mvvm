import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CampoCadastro extends StatelessWidget {
  final TextEditingController controlador;
  final String rotulo;
  final String? erro;
  final IconData? icone;
  final Widget? sufixo;
  final TextInputType? teclado;
  final TextInputFormatter? mascara;
  final TextCapitalization capitalizacao;
  final String? dicaAutomatica;
  final String? exemplo;
  final VoidCallback? aoEnviar;

  const CampoCadastro({
    required this.controlador,
    required this.rotulo,
    required this.erro,
    this.icone,
    this.sufixo,
    this.teclado,
    this.mascara,
    this.capitalizacao = TextCapitalization.none,
    this.dicaAutomatica,
    this.exemplo,
    this.aoEnviar,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mascara = this.mascara;
    final icone = this.icone;
    final dica = dicaAutomatica;
    final aoEnviar = this.aoEnviar;
    return TextField(
      controller: controlador,
      keyboardType: teclado,
      inputFormatters: mascara == null ? null : [mascara],
      textCapitalization: capitalizacao,
      autofillHints: dica == null ? null : [dica],
      textInputAction: aoEnviar == null
          ? TextInputAction.next
          : TextInputAction.done,
      onSubmitted: aoEnviar == null ? null : (_) => aoEnviar(),
      decoration: InputDecoration(
        labelText: rotulo,
        hintText: exemplo,
        errorText: erro,
        errorMaxLines: 2,
        prefixIcon: icone == null ? null : Icon(icone),
        suffixIcon: sufixo,
      ),
    );
  }
}
