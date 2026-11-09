import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/coordenada.dart';
import '../models/deslocamento.dart';
import 'falhas.dart';

/// US11: distância, tempo e rota até o cliente pela Routes API (RF16, RNF08).
class RotaService {
  final http.Client _cliente;
  final String _chaveApi;

  RotaService(this._cliente, this._chaveApi);

  static const enderecoDeposito =
      'Roma Auto Center, R. Elizeo Schmitt - Centro, Dona Emma - SC, 89155-000';

  Future<Deslocamento> calcularDeslocamento(String destino) async {
    if (_chaveApi.isEmpty) throw const FalhaRota();
    try {
      final resposta = await _cliente
          .post(
            Uri.parse(
              'https://routes.googleapis.com/directions/v2:computeRoutes',
            ),
            headers: {
              'Content-Type': 'application/json',
              'X-Goog-Api-Key': _chaveApi,
              'X-Goog-FieldMask':
                  'routes.distanceMeters,routes.duration,'
                  'routes.polyline.encodedPolyline',
            },
            body: jsonEncode({
              'origin': {'address': enderecoDeposito},
              'destination': {'address': '$destino, SC, Brasil'},
              'travelMode': 'DRIVE',
              'languageCode': 'pt-BR',
              'regionCode': 'BR',
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (resposta.statusCode != 200) throw const FalhaRota();

      final corpo = jsonDecode(resposta.body);
      final rotas = corpo is Map ? corpo['routes'] : null;
      if (rotas is! List || rotas.isEmpty || rotas.first is! Map) {
        throw const FalhaRota();
      }
      final rota = rotas.first as Map;
      final distancia = rota['distanceMeters'] ?? 0;
      final duracao = rota['duration'] ?? '0s';
      if (distancia is! num || duracao is! String || !duracao.endsWith('s')) {
        throw const FalhaRota();
      }
      final segundos = double.tryParse(
        duracao.substring(0, duracao.length - 1),
      );
      if (segundos == null) throw const FalhaRota();
      final linha = rota['polyline'];
      final codificada = linha is Map ? linha['encodedPolyline'] : null;
      final polilinha = codificada is String ? codificada : null;

      return Deslocamento(
        distanciaMetros: distancia.toInt(),
        duracaoSegundos: segundos.round(),
        polilinha: polilinha,
      );
    } on TimeoutException {
      throw const FalhaRota();
    } on SocketException {
      throw const FalhaRota();
    } on http.ClientException {
      throw const FalhaRota();
    } on FormatException {
      throw const FalhaRota();
    }
  }

  List<Coordenada> decodificarRota(String polilinha) {
    final pontos = <Coordenada>[];
    var indice = 0;
    var latitude = 0;
    var longitude = 0;
    int proximo() {
      var resultado = 0;
      var deslocamento = 0;
      int byte;
      do {
        byte = polilinha.codeUnitAt(indice++) - 63;
        resultado |= (byte & 0x1F) << deslocamento;
        deslocamento += 5;
      } while (byte >= 0x20);
      return (resultado & 1) != 0 ? ~(resultado >> 1) : resultado >> 1;
    }

    try {
      while (indice < polilinha.length) {
        latitude += proximo();
        longitude += proximo();
        pontos.add(Coordenada(latitude / 1e5, longitude / 1e5));
      }
    } on RangeError {
      return [];
    }
    return pontos;
  }
}
