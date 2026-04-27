import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/pelicula_vista.dart';
import '../services/peliculas_repository.dart';

class MisPeliculasPage extends StatefulWidget {
  const MisPeliculasPage({super.key});

  @override
  State<MisPeliculasPage> createState() => _MisPeliculasPageState();
}

class _MisPeliculasPageState extends State<MisPeliculasPage> {
  final _repo = PeliculasRepository();
  String _filtro = ''; // Filtro de búsqueda local.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis películas'),
      ),

      // FAB para registrar una nueva película.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/agregar-pelicula'),
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),

      body: Column(
        children: [
          // Buscador (TextField + setState).
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por título o género…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _filtro = v.toLowerCase().trim()),
            ),
          ),

          // Lista reactiva con ValueListenableBuilder (Hive).
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _repo.escuchar(),
              builder: (context, Box<PeliculaVista> box, _) {
                // Aplicamos el orden y filtro.
                var lista = _repo.obtenerTodas();
                if (_filtro.isNotEmpty) {
                  lista = lista.where((p) =>
                    p.titulo.toLowerCase().contains(_filtro) ||
                    p.genero.toLowerCase().contains(_filtro)
                  ).toList();
                }

                if (lista.isEmpty) {
                  return _EstadoVacio(filtroActivo: _filtro.isNotEmpty);
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: lista.length,
                  itemBuilder: (context, i) {
                    final p = lista[i];

                    // Dismissible para eliminar deslizando.
                    return Dismissible(
                      key: ValueKey(p.key),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        await _repo.eliminar(p);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Eliminaste "${p.titulo}"')),
                        );
                      },
                      child: _PeliculaCard(pelicula: p),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PeliculaCard extends StatelessWidget {
  final PeliculaVista pelicula;
  const _PeliculaCard({required this.pelicula});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stack: poster con badge de estrellas encima.
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _miniatura(),
                ),
                Positioned(
                  bottom: 4, left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          pelicula.calificacion.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pelicula.titulo,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('${pelicula.genero} · ${pelicula.anio}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  if (pelicula.lugar != null && pelicula.lugar!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place, size: 12, color: Colors.redAccent),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            pelicula.lugar!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  if (pelicula.comentario.isNotEmpty)
                    Text(
                      pelicula.comentario,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  const SizedBox(height: 6),
                  // Estrellas animadas.
                  Row(
                    children: List.generate(5, (i) {
                      final filled = i < pelicula.calificacion.round();
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          filled ? Icons.star : Icons.star_border,
                          key: ValueKey(filled),
                          size: 16,
                          color: Colors.amber,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Devuelve la miniatura priorizando: foto local > URL del catálogo > placeholder.
  Widget _miniatura() {
    if (pelicula.rutaFotoLocal != null) {
      final f = File(pelicula.rutaFotoLocal!);
      if (f.existsSync()) {
        return Image.file(f, width: 80, height: 110, fit: BoxFit.cover);
      }
    }
    if (pelicula.imagenUrl != null) {
      return Image.network(
        pelicula.imagenUrl!,
        width: 80, height: 110, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 80, height: 110,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: const Icon(Icons.movie, size: 32, color: Colors.white),
    );
  }
}

// Estado vacío con animación.
class _EstadoVacio extends StatefulWidget {
  final bool filtroActivo;
  const _EstadoVacio({required this.filtroActivo});

  @override
  State<_EstadoVacio> createState() => _EstadoVacioState();
}

class _EstadoVacioState extends State<_EstadoVacio>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.05).animate(
              CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
            ),
            child: const Icon(Icons.movie_creation_outlined,
                size: 96, color: Colors.deepPurple),
          ),
          const SizedBox(height: 16),
          Text(
            widget.filtroActivo
                ? 'Sin coincidencias'
                : 'Aún no registras películas',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Toca "Agregar" para empezar tu colección',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
