import 'package:flutter/services.dart';

class MascaraNumerica extends TextInputFormatter {
  final String padrao;

  const MascaraNumerica(this.padrao);

  static const telefone = MascaraNumerica('(##) #####-####');
  static const cpf = MascaraNumerica('###.###.###-##');
  static const data = MascaraNumerica('##/##/####');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue antigo,
    TextEditingValue novo,
  ) {
    final digitos = novo.text.replaceAll(RegExp(r'\D'), '');
    final texto = StringBuffer();
    var indice = 0;
    for (final caractere in padrao.split('')) {
      if (indice >= digitos.length) break;
      if (caractere == '#') {
        texto.write(digitos[indice++]);
      } else {
        texto.write(caractere);
      }
    }
    final resultado = texto.toString();
    final cursor = novo.selection.end.clamp(0, novo.text.length);
    final digitosAntes = novo.text
        .substring(0, cursor)
        .replaceAll(RegExp(r'\D'), '')
        .length;
    var posicao = 0;
    var contados = 0;
    while (contados < digitosAntes && posicao < resultado.length) {
      if (RegExp(r'\d').hasMatch(resultado[posicao])) contados++;
      posicao++;
    }
    if (cursor == novo.text.length) posicao = resultado.length;
    return TextEditingValue(
      text: resultado,
      selection: TextSelection.collapsed(offset: posicao),
    );
  }
}
