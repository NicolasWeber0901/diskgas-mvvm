class Deslocamento {
  final int distanciaMetros;
  final int duracaoSegundos;

  const Deslocamento({
    required this.distanciaMetros,
    required this.duracaoSegundos,
  });

  double get distanciaKm => distanciaMetros / 1000;

  int get duracaoMinutos => (duracaoSegundos / 60).ceil();
}
