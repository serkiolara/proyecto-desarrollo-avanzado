import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// Resultado de obtener la ubicación: coordenadas + dirección legible.
class UbicacionResultado {
  final double latitud;
  final double longitud;
  final String? lugar; // Dirección legible derivada de geocoding inverso.

  UbicacionResultado({
    required this.latitud,
    required this.longitud,
    this.lugar,
  });
}

// Excepción específica del servicio para que la UI pueda diferenciar errores.
class UbicacionException implements Exception {
  final String mensaje;
  UbicacionException(this.mensaje);
  @override
  String toString() => mensaje;
}

// Servicio que encapsula la obtención de la ubicación del dispositivo
// y el geocoding inverso para tener una dirección legible.
class UbicacionService {

  // Devuelve la ubicación actual o lanza UbicacionException con el motivo.
  Future<UbicacionResultado> obtenerUbicacionActual() async {
    // Verifica que el GPS esté encendido.
    final servicioActivo = await Geolocator.isLocationServiceEnabled();
    if (!servicioActivo) {
      throw UbicacionException('El GPS está apagado. Actívalo para continuar.');
    }

    // Solicita permisos.
    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (permiso == LocationPermission.denied) {
      throw UbicacionException('Permiso de ubicación denegado.');
    }
    if (permiso == LocationPermission.deniedForever) {
      throw UbicacionException(
        'Permiso de ubicación bloqueado. Habilítalo desde los ajustes.',
      );
    }

    // Lee la posición actual.
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );

    // Geocoding inverso: traduce lat/lng a una dirección legible.
    String? lugar;
    try {
      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final pm = placemarks.first;
        final partes = <String?>[
          pm.street,
          pm.subLocality,
          pm.locality,
          pm.administrativeArea,
          pm.country,
        ].where((s) => s != null && s.trim().isNotEmpty).toList();
        lugar = partes.join(', ');
      }
    } catch (_) {
      // Si falla el geocoding, devolvemos solo coordenadas.
      lugar = null;
    }

    return UbicacionResultado(
      latitud: pos.latitude,
      longitud: pos.longitude,
      lugar: lugar,
    );
  }
}
