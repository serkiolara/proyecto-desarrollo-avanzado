import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';
import '../models/pelicula_vista.dart';
import '../services/peliculas_repository.dart';

// Pantalla con mapa que muestra un marcador por cada película registrada
// con coordenadas. Usa flutter_map sobre tiles de OpenStreetMap.
class MisCinesPage extends StatefulWidget {
  const MisCinesPage({super.key});

  @override
  State<MisCinesPage> createState() => _MisCinesPageState();
}

class _MisCinesPageState extends State<MisCinesPage> {
  final _repo = PeliculasRepository();
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis cines')),
      body: ValueListenableBuilder(
        valueListenable: _repo.escuchar(),
        builder: (context, Box<PeliculaVista> box, _) {
          final geolocalizadas = box.values
              .where((p) => p.latitud != null && p.longitud != null)
              .toList();

          if (geolocalizadas.isEmpty) {
            return const _SinUbicaciones();
          }

          // Centro inicial: promedio de las coordenadas.
          final centro = LatLng(
            geolocalizadas
                    .map((p) => p.latitud!)
                    .reduce((a, b) => a + b) /
                geolocalizadas.length,
            geolocalizadas
                    .map((p) => p.longitud!)
                    .reduce((a, b) => a + b) /
                geolocalizadas.length,
          );

          final marcadores = geolocalizadas.map((p) {
            return Marker(
              point: LatLng(p.latitud!, p.longitud!),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _mostrarFicha(p),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.redAccent,
                  size: 40,
                ),
              ),
            );
          }).toList();

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: centro,
              initialZoom: 5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.equipo.mispelis',
                maxZoom: 19,
              ),
              MarkerLayer(markers: marcadores),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('© OpenStreetMap contributors'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _mostrarFicha(PeliculaVista p) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.titulo,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${p.genero} · ${p.anio}',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.place, size: 16, color: Colors.redAccent),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    p.lugar ??
                        'Lat: ${p.latitud!.toStringAsFixed(5)}, '
                            'Lng: ${p.longitud!.toStringAsFixed(5)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(p.calificacion.toStringAsFixed(1)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SinUbicaciones extends StatelessWidget {
  const _SinUbicaciones();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.map_outlined, size: 96, color: Colors.deepPurple),
            SizedBox(height: 12),
            Text('Aún no tienes películas con ubicación',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(
              'Al registrar una película toca "Usar mi ubicación" para verla aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
