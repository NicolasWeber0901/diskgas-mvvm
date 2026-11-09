const _comAcento = 'áàâãäéèêëíìîïóòôõöúùûüç';
const _semAcento = 'aaaaaeeeeiiiiooooouuuuc';

String normalizarBusca(String texto) {
  final resultado = StringBuffer();
  for (final letra in texto.trim().toLowerCase().split('')) {
    final posicao = _comAcento.indexOf(letra);
    resultado.write(posicao == -1 ? letra : _semAcento[posicao]);
  }
  return resultado.toString();
}
