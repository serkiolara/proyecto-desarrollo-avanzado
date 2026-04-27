import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/pelicula_vista.dart';

// Repositorio que abstrae las operaciones de Hive sobre PeliculaVista.
// Mantiene el código de UI separado de la capa de persistencia.
class PeliculasRepository {
  static const String _boxName = 'peliculas_vistas';

  // Inicializa Hive y abre la caja. Se llama una sola vez en main().
  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PeliculaVistaAdapter());
    }
    await Hive.openBox<PeliculaVista>(_boxName);
  }

  // Acceso directo a la caja (ya abierta en init).
  Box<PeliculaVista> get _box => Hive.box<PeliculaVista>(_boxName);

  // Devuelve todas las películas vistas, ordenadas de más reciente a más antigua.
  List<PeliculaVista> obtenerTodas() {
    final lista = _box.values.toList();
    lista.sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));
    return lista;
  }

  // Listenable para refrescar la UI con ValueListenableBuilder.
  ValueListenable<Box<PeliculaVista>> escuchar() => _box.listenable();

  // Guarda una nueva película vista.
  Future<void> agregar(PeliculaVista p) async {
    await _box.add(p);
  }

  // Actualiza una película existente (ya está vinculada al box vía HiveObject).
  Future<void> actualizar(PeliculaVista p) async {
    await p.save();
  }

  // Elimina una película.
  Future<void> eliminar(PeliculaVista p) async {
    await p.delete();
  }

  // Promedio de calificaciones (útil para mostrar en Home).
  double promedioCalificaciones() {
    final lista = _box.values.toList();
    if (lista.isEmpty) return 0;
    final suma = lista.fold<double>(0, (acc, p) => acc + p.calificacion);
    return suma / lista.length;
  }

  int get total => _box.length;
}
