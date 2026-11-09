String formatarPreco(double valor) =>
    'R\$\u00A0${valor.toStringAsFixed(2).replaceAll('.', ',')}';

String _doisDigitos(int valor) => valor.toString().padLeft(2, '0');

String formatarDataCurta(DateTime data) =>
    '${_doisDigitos(data.day)}/${_doisDigitos(data.month)}/${data.year}';

String formatarData(DateTime data) =>
    '${formatarDataCurta(data)} '
    '${_doisDigitos(data.hour)}:${_doisDigitos(data.minute)}';

String mascararCpf(String cpf) {
  if (cpf.length != 11) return cpf;
  return '***.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-**';
}

String formatarTelefone(String telefone) {
  final digitos = telefone.replaceAll(RegExp(r'\D'), '');
  if (digitos.length == 11) {
    return '(${digitos.substring(0, 2)}) '
        '${digitos.substring(2, 7)}-${digitos.substring(7)}';
  }
  if (digitos.length == 10) {
    return '(${digitos.substring(0, 2)}) '
        '${digitos.substring(2, 6)}-${digitos.substring(6)}';
  }
  return telefone;
}
