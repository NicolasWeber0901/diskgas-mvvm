import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/coordenada.dart';
import '../tema.dart';

const _esperaParaEnquadrar = Duration(milliseconds: 300);
const _tentativasDeEnquadrar = 4;

class MapaRota extends StatefulWidget {
  final List<Coordenada> rota;
  final String cliente;

  const MapaRota({required this.rota, required this.cliente, super.key});

  @override
  State<MapaRota> createState() => _MapaRotaState();
}

class _MapaRotaState extends State<MapaRota> {
  LatLngBounds _limites() {
    final latitudes = widget.rota.map((ponto) => ponto.latitude);
    final longitudes = widget.rota.map((ponto) => ponto.longitude);
    return LatLngBounds(
      southwest: LatLng(latitudes.reduce(min), longitudes.reduce(min)),
      northeast: LatLng(latitudes.reduce(max), longitudes.reduce(max)),
    );
  }

  void _enquadrar(GoogleMapController controlador, [int tentativa = 1]) {
    if (widget.rota.length < 2) return;
    Future<void>.delayed(_esperaParaEnquadrar * tentativa, () {
      if (!mounted) return;
      controlador
          .animateCamera(CameraUpdate.newLatLngBounds(_limites(), 48))
          .onError<PlatformException>((_, _) {
            if (tentativa < _tentativasDeEnquadrar) {
              _enquadrar(controlador, tentativa + 1);
            }
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    final pontos = [
      for (final ponto in widget.rota) LatLng(ponto.latitude, ponto.longitude),
    ];
    return Semantics(
      label: 'Mapa com a rota do depósito até o cliente',
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: pontos.first, zoom: 14),
          polylines: {
            Polyline(
              polylineId: const PolylineId('rota'),
              points: pontos,
              color: CoresDiskGas.laranjaBotao,
              width: 5,
            ),
          },
          markers: {
            Marker(
              markerId: const MarkerId('deposito'),
              position: pontos.first,
              infoWindow: const InfoWindow(title: 'Depósito'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
            ),
            Marker(
              markerId: const MarkerId('cliente'),
              position: pontos.last,
              infoWindow: InfoWindow(title: widget.cliente),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange,
              ),
            ),
          },
          zoomControlsEnabled: true,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          gestureRecognizers: {
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
          onMapCreated: _enquadrar,
        ),
      ),
    );
  }
}
