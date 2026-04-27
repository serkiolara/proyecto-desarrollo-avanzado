import 'dart:io';
import 'package:flutter/material.dart';
import '../models/pelicula_vista.dart';
import '../services/peliculas_repository.dart';
import '../services/camara_service.dart';
import '../services/ubicacion_service.dart';

// Pantalla con formulario para registrar una película vista.
// Se puede abrir vacía (desde Home) o precargada desde el catálogo de la API
// pasando un Map como argumento de la ruta.
class AgregarPeliculaPage extends StatefulWidget {
  const AgregarPeliculaPage({super.key});

  @override
  State<AgregarPeliculaPage> createState() => _AgregarPeliculaPageState();
}

class _AgregarPeliculaPageState extends State<AgregarPeliculaPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl     = TextEditingController();
  final _generoCtrl     = TextEditingController();
  final _anioCtrl       = TextEditingController();
  final _comentarioCtrl = TextEditingController();
  final _repo    = PeliculasRepository();
  final _camara  = CamaraService();
  final _gps     = UbicacionService();

  double _calificacion = 3;
  String? _imagenUrl;       // Poster del catálogo (URL remota).
  String? _rutaFotoLocal;   // Foto tomada por el usuario.
  double? _latitud;
  double? _longitud;
  String? _lugar;
  bool _cargandoUbicacion = false;
  bool _argsAplicados = false;

  // Lista de géneros disponibles (uso de colecciones de Dart).
  final List<String> _generos = const [
    'Acción', 'Aventura', 'Comedia', 'Drama', 'Terror',
    'Ciencia Ficción', 'Romance', 'Animación', 'Documental', 'Fantasía',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsAplicados) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _tituloCtrl.text = (args['titulo'] ?? '').toString();
      _generoCtrl.text = (args['genero'] ?? '').toString();
      _anioCtrl.text   = (args['anio'] ?? '').toString();
      _imagenUrl       = args['imagenUrl'] as String?;
      if (args['calificacion'] is num) {
        _calificacion = (args['calificacion'] as num).toDouble().clamp(1, 5);
      }
    }
    _argsAplicados = true;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _generoCtrl.dispose();
    _anioCtrl.dispose();
    _comentarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _tomarFoto() async {
    try {
      final ruta = await _camara.tomarFoto();
      if (ruta != null) setState(() => _rutaFotoLocal = ruta);
    } catch (e) {
      _mostrarMensaje('No se pudo abrir la cámara');
    }
  }

  Future<void> _elegirDeGaleria() async {
    try {
      final ruta = await _camara.elegirDeGaleria();
      if (ruta != null) setState(() => _rutaFotoLocal = ruta);
    } catch (e) {
      _mostrarMensaje('No se pudo abrir la galería');
    }
  }

  Future<void> _capturarUbicacion() async {
    setState(() => _cargandoUbicacion = true);
    try {
      final r = await _gps.obtenerUbicacionActual();
      setState(() {
        _latitud  = r.latitud;
        _longitud = r.longitud;
        _lugar    = r.lugar;
      });
    } on UbicacionException catch (e) {
      _mostrarMensaje(e.mensaje);
    } catch (_) {
      _mostrarMensaje('No se pudo obtener la ubicación');
    } finally {
      if (mounted) setState(() => _cargandoUbicacion = false);
    }
  }

  void _quitarFoto()     => setState(() => _rutaFotoLocal = null);
  void _quitarUbicacion() => setState(() {
    _latitud = null; _longitud = null; _lugar = null;
  });

  void _mostrarMensaje(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final p = PeliculaVista(
      titulo:        _tituloCtrl.text.trim(),
      genero:        _generoCtrl.text.trim(),
      anio:          int.parse(_anioCtrl.text.trim()),
      calificacion:  _calificacion,
      comentario:    _comentarioCtrl.text.trim(),
      fechaRegistro: DateTime.now(),
      imagenUrl:     _imagenUrl,
      rutaFotoLocal: _rutaFotoLocal,
      latitud:       _latitud,
      longitud:      _longitud,
      lugar:         _lugar,
    );

    await _repo.agregar(p);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${p.titulo}" agregada a tu colección')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar película')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _bloqueImagen(),
            const SizedBox(height: 16),

            // Título.
            TextFormField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(
                labelText: 'Título',
                prefixIcon: Icon(Icons.movie_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'El título es obligatorio';
                if (v.trim().length < 2)           return 'Mínimo 2 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Género.
            DropdownButtonFormField<String>(
              initialValue: _generos.contains(_generoCtrl.text)
                  ? _generoCtrl.text
                  : null,
              decoration: const InputDecoration(
                labelText: 'Género',
                prefixIcon: Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
              ),
              items: _generos
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) {
                if (v != null) _generoCtrl.text = v;
              },
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Selecciona un género' : null,
            ),
            const SizedBox(height: 12),

            // Año.
            TextFormField(
              controller: _anioCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Año',
                prefixIcon: Icon(Icons.calendar_today_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Año obligatorio';
                final n = int.tryParse(v.trim());
                if (n == null)             return 'Debe ser un número';
                if (n < 1900 || n > 2100)  return 'Año fuera de rango';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Calificación.
            const Text('Tu calificación',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final activa = i < _calificacion.round();
                return GestureDetector(
                  onTap: () => setState(() => _calificacion = (i + 1).toDouble()),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: EdgeInsets.all(activa ? 6 : 4),
                    decoration: BoxDecoration(
                      color: activa
                          ? Colors.amber.withValues(alpha: 0.2)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      activa ? Icons.star_rounded : Icons.star_border_rounded,
                      size: activa ? 40 : 34,
                      color: activa ? Colors.amber : Colors.grey,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                '${_calificacion.toStringAsFixed(0)} / 5',
                style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),

            // Comentario.
            TextFormField(
              controller: _comentarioCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Comentario (opcional)',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            _bloqueUbicacion(cs),
            const SizedBox(height: 24),

            FilledButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Guardar'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _guardar,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────── Sub-bloques ───────────────

  Widget _bloqueImagen() {
    Widget preview;
    if (_rutaFotoLocal != null) {
      preview = ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(
          File(_rutaFotoLocal!),
          height: 200, width: double.infinity, fit: BoxFit.cover,
        ),
      );
    } else if (_imagenUrl != null) {
      preview = ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          _imagenUrl!,
          height: 200, width: double.infinity, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholderFoto(),
        ),
      );
    } else {
      preview = _placeholderFoto();
    }

    return Column(
      children: [
        preview,
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _tomarFoto,
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Cámara'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _elegirDeGaleria,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galería'),
              ),
            ),
            if (_rutaFotoLocal != null) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Quitar foto',
                onPressed: _quitarFoto,
                icon: const Icon(Icons.close),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _placeholderFoto() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 6),
          Text('Sin imagen', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _bloqueUbicacion(ColorScheme cs) {
    final tieneUbicacion = _latitud != null && _longitud != null;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.place_outlined, color: cs.primary),
                const SizedBox(width: 8),
                const Text('Ubicación',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (tieneUbicacion)
                  IconButton(
                    tooltip: 'Quitar ubicación',
                    onPressed: _quitarUbicacion,
                    icon: const Icon(Icons.close, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (tieneUbicacion)
              Text(
                _lugar ??
                    'Lat: ${_latitud!.toStringAsFixed(5)}, Lng: ${_longitud!.toStringAsFixed(5)}',
                style: const TextStyle(fontSize: 13),
              )
            else
              const Text('Sin ubicación capturada',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _cargandoUbicacion ? null : _capturarUbicacion,
                icon: _cargandoUbicacion
                    ? const SizedBox(
                        height: 16, width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(tieneUbicacion
                    ? 'Actualizar ubicación'
                    : 'Usar mi ubicación'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
