String formatarPreco(double valor) =>
    'R\$\u00A0${valor.toStringAsFixed(2).replaceAll('.', ',')}';

String formatarData(DateTime data) {
  String doisDigitos(int valor) => valor.toString().padLeft(2, '0');
  return '${doisDigitos(data.day)}/${doisDigitos(data.month)}/${data.year} '
      '${doisDigitos(data.hour)}:${doisDigitos(data.minute)}';
}

String mascararCpf(String cpf) {
  if (cpf.length != 11) return cpf;
  return '***.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-**';
}

String formatarTelefone(String telefone) {
  final d = telefone.replaceAll(RegExp(r'\D'), '');
  if (d.length == 11) {
    return '(${d.substring(0, 2)}) ${d.substring(2, 7)}-${d.substring(7)}';
  }
  if (d.length == 10) {
    return '(${d.substring(0, 2)}) ${d.substring(2, 6)}-${d.substring(6)}';
  }
  return telefone;
}
