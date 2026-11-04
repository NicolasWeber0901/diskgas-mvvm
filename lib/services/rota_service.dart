import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/deslocamento.dart';
import 'falhas.dart';

/// US11: distância e tempo até o cliente pela Routes API (RF16, RNF08).
class RotaService {
  final http.Client _cliente;
  final String _chaveApi;

  RotaService(this._cliente, this._chaveApi);

  static const enderecoDeposito =
      'Roma Auto Center, R. Elizeo Schmitt - Centro, Dona Emma - SC, 89155-000';

  Future<Deslocamento> calcularDeslocamento(String destino) async {
    if (_chaveApi.isEmpty) throw const FalhaRota();
    try {
      final resposta = await _cliente.post(
        Uri.parse(
          'https://routes.googleapis.com/distanceMatrix/v2:computeRouteMatrix',
        ),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _chaveApi,
          'X-Goog-FieldMask':
              'originIndex,destinationIndex,status,condition,'
              'distanceMeters,duration',
        },
        body: jsonEncode({
          'origins': [
            {
              'waypoint': {'address': enderecoDeposito},
            },
          ],
          'destinations': [
            {
              'waypoint': {'address': destino},
            },
          ],
          'travelMode': 'DRIVE',
          'languageCode': 'pt-BR',
          'regionCode': 'BR',
        }),
      );
      if (resposta.statusCode != 200) throw const FalhaRota();

      final lista = jsonDecode(resposta.body);
      if (lista is! List || lista.isEmpty || lista.first is! Map) {
        throw const FalhaRota();
      }
      final elemento = lista.first as Map;
      final distancia = elemento['distanceMeters'];
      final duracao = elemento['duration'];
      if (elemento['condition'] != 'ROUTE_EXISTS' ||
          distancia is! num ||
          duracao is! String ||
          !duracao.endsWith('s')) {
        throw const FalhaRota();
      }
      final segundos = double.tryParse(
        duracao.substring(0, duracao.length - 1),
      );
      if (segundos == null) throw const FalhaRota();

      return Deslocamento(
        distanciaMetros: distancia.toInt(),
        duracaoSegundos: segundos.round(),
      );
    } on SocketException {
      throw const FalhaRota();
    } on http.ClientException {
      throw const FalhaRota();
    } on FormatException {
      throw const FalhaRota();
    }
  }
}
