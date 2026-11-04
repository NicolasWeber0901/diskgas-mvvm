String formatarPreco(double valor) =>
    'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

String formatarData(DateTime data) {
  String doisDigitos(int valor) => valor.toString().padLeft(2, '0');
  return '${doisDigitos(data.day)}/${doisDigitos(data.month)}/${data.year} '
      '${doisDigitos(data.hour)}:${doisDigitos(data.minute)}';
}
