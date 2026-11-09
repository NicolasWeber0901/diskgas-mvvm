import 'package:flutter/material.dart';

class CampoSenha extends StatefulWidget {
  final TextEditingController controlador;
  final String? erro;
  final String? ajuda;
  final String dicaAutomatica;
  final VoidCallback? aoEnviar;

  const CampoSenha({
    required this.controlador,
    required this.dicaAutomatica,
    this.erro,
    this.ajuda,
    this.aoEnviar,
    super.key,
  });

  @override
  State<CampoSenha> createState() => _CampoSenhaState();
}

class _CampoSenhaState extends State<CampoSenha> {
  bool _oculta = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controlador,
      obscureText: _oculta,
      autofillHints: [widget.dicaAutomatica],
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => widget.aoEnviar?.call(),
      decoration: InputDecoration(
        labelText: 'Senha',
        errorText: widget.erro,
        helperText: widget.ajuda,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: _oculta ? 'Mostrar senha' : 'Ocultar senha',
          icon: Icon(
            _oculta ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _oculta = !_oculta),
        ),
      ),
    );
  }
}
