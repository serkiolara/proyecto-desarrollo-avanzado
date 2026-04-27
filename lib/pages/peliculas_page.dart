import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/pelicula.dart';

class PeliculasPage extends StatefulWidget {
  PeliculasPage({super.key});

  @override
  State<PeliculasPage> createState() => _PeliculasPageState();
}

class _PeliculasPageState extends State<PeliculasPage> {
  final ApiService apiService = ApiService();
  late Future<List<Pelicula>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = apiService.obtenerPeliculas();
  }

  Future<void> _recargar() async {
    setState(() => _futuro = apiService.obtenerPeliculas());
    await _futuro;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de películas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _recargar,
          ),
        ],
      ),

      body: FutureBuilder<List<Pelicula>>(
        future: _futuro,
        builder: (context, snapshot) {
          // Estado de carga.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Estado de error con botón de reintento.
          if (snapshot.hasError) {
            return _ErrorEstado(onRetry: _recargar, mensaje: '${snapshot.error}');
          }

          final peliculas = snapshot.data ?? [];
          if (peliculas.isEmpty) {
            return const Center(child: Text('Sin películas en el catálogo'));
          }

          // GridView para mostrar el catálogo en mosaico.
          return RefreshIndicator(
            onRefresh: _recargar,
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: peliculas.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.62,
              ),
              itemBuilder: (context, index) {
                final p = peliculas[index];
                return _PeliculaTile(pelicula: p);
              },
            ),
          );
        },
      ),
    );
  }
}

class _PeliculaTile extends StatelessWidget {
  final Pelicula pelicula;
  const _PeliculaTile({required this.pelicula});

  void _registrarComoVista(BuildContext context) {
    // Abre el formulario de "Agregar" precargando los datos.
    Navigator.pushNamed(
      context,
      '/agregar-pelicula',
      arguments: {
        'titulo':       pelicula.title,
        'genero':       pelicula.genre,
        'anio':         pelicula.year,
        'imagenUrl':    pelicula.imageUrl,
        'calificacion': pelicula.stars.clamp(1, 5),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _mostrarDetalle(context),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Poster.
            Hero(
              tag: 'pelicula-${pelicula.id}',
              child: Image.network(
                pelicula.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.movie, size: 48, color: Colors.white),
                ),
              ),
            ),
            // Degradado oscuro inferior.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Estrellas.
            Positioned(
              top: 8, right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      pelicula.stars.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            // Título y géneros.
            Positioned(
              left: 10, right: 10, bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pelicula.title,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${pelicula.genre} · ${pelicula.year}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size.fromHeight(32),
                      ),
                      onPressed: () => _registrarComoVista(context),
                      icon: const Icon(Icons.bookmark_add, size: 16),
                      label: const Text('Vi esta',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetalle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'pelicula-${pelicula.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    pelicula.imageUrl,
                    height: 240, width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(height: 240),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(pelicula.title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${pelicula.genre} · ${pelicula.year}',
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(pelicula.stars.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Text(pelicula.description),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _registrarComoVista(context);
                },
                icon: const Icon(Icons.bookmark_add),
                label: const Text('Marcar como vista'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorEstado extends StatelessWidget {
  final VoidCallback onRetry;
  final String mensaje;
  const _ErrorEstado({required this.onRetry, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 72, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('No se pudo cargar el catálogo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(mensaje,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
