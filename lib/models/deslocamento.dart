class Deslocamento {
  final int distanciaMetros;
  final int duracaoSegundos;
  final String? polilinha;

  const Deslocamento({
    required this.distanciaMetros,
    required this.duracaoSegundos,
    this.polilinha,
  });

  double get distanciaKm => distanciaMetros / 1000;

  int get duracaoMinutos => (duracaoSegundos / 60).ceil();
}
