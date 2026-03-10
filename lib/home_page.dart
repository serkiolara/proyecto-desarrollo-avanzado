import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {

    // Se reciben los argumentos enviados desde LoginPage.
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final correo = args['correo'] as String;

    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenido, $correo',
              style: const TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.people),
              label: const Text('Ver usuarios'),
              onPressed: () {
                Navigator.pushNamed(context, '/usuarios'); // Navega a la pantalla de usuarios de la API.
              },
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              icon: const Icon(Icons.movie),
              label: const Text('Ver catálogo de películas'),
              onPressed: () {
                Navigator.pushNamed(context, '/peliculas'); // Navega a la pantalla del catálogo de películas.
              },
            ),
          ],
        ),
      ),
    );
  }
}
