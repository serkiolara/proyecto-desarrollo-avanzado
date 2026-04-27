import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/pelicula_vista.dart';
import 'services/peliculas_repository.dart';
import 'services/preferencias_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _repo = PeliculasRepository();
  final _prefs = PreferenciasService();

  Future<void> _cerrarSesion() async {
    await _prefs.cerrarSesion();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Se reciben los argumentos enviados desde LoginPage (correo del usuario).
    final args   = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final correo = (args['correo'] as String?) ?? '';

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MisPelis'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary, cs.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hola,',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    correo.isEmpty ? 'Cinéfilo' : correo,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('¿Qué viste hoy?',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Resumen en tiempo real (Hive listenable).
            ValueListenableBuilder(
              valueListenable: _repo.escuchar(),
              builder: (context, Box<PeliculaVista> box, _) {
                final total = box.length;
                final prom  = _repo.promedioCalificaciones();
                return Row(
                  children: [
                    Expanded(child: _Stat(
                      icon: Icons.movie_outlined,
                      label: 'Películas',
                      value: '$total',
                      color: cs.primary,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _Stat(
                      icon: Icons.star_rounded,
                      label: 'Promedio',
                      value: prom == 0 ? '—' : prom.toStringAsFixed(1),
                      color: Colors.amber.shade700,
                    )),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            const Text('Explorar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // GridView con las opciones principales.
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _OpcionCard(
                  icon: Icons.collections_bookmark,
                  titulo: 'Mis películas',
                  descripcion: 'Tu registro personal',
                  color: cs.primary,
                  onTap: () => Navigator.pushNamed(context, '/mis-peliculas'),
                ),
                _OpcionCard(
                  icon: Icons.add_circle_outline,
                  titulo: 'Agregar',
                  descripcion: 'Registrar película vista',
                  color: Colors.green.shade600,
                  onTap: () => Navigator.pushNamed(context, '/agregar-pelicula'),
                ),
                _OpcionCard(
                  icon: Icons.movie,
                  titulo: 'Catálogo',
                  descripcion: 'Películas desde la API',
                  color: Colors.deepOrange,
                  onTap: () => Navigator.pushNamed(context, '/peliculas'),
                ),
                _OpcionCard(
                  icon: Icons.map_outlined,
                  titulo: 'Mis cines',
                  descripcion: 'Mapa de ubicaciones',
                  color: Colors.teal,
                  onTap: () => Navigator.pushNamed(context, '/mis-cines'),
                ),
                _OpcionCard(
                  icon: Icons.people,
                  titulo: 'Usuarios',
                  descripcion: 'Demo API JSONPlaceholder',
                  color: Colors.blueGrey,
                  onTap: () => Navigator.pushNamed(context, '/usuarios'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OpcionCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String descripcion;
  final Color color;
  final VoidCallback onTap;
  const _OpcionCard({
    required this.icon,
    required this.titulo,
    required this.descripcion,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 16),
              Text(titulo,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(descripcion,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
