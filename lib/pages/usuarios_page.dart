import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/usuario.dart';

class UsuariosPage extends StatelessWidget {

  final ApiService apiService = ApiService();

  UsuariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),

      body: FutureBuilder<List<Usuario>>(
        future: apiService.obtenerUsuarios(),

        builder: (context, snapshot) {
          // snapshot contiene los datos recibidos, el error si ocurrió, y el estado de carga.

          if (snapshot.hasData) { // La API ya respondió y hay datos disponibles.
            List<Usuario> usuarios = snapshot.data!; // El valor no es null.

            // ListView.builder crea los elementos solo cuando se necesitan al hacer scroll.
            return ListView.builder(
              itemCount: usuarios.length,
              itemBuilder: (context, index) {

                final usuario = usuarios[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(Icons.person), // Icono de usuario.
                    title: Text(usuario.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(usuario.email),
                        Text(usuario.phone),
                        Text(usuario.website),
                      ],
                    ),
                  ),
                );

              },
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Error al cargar datos'),
            );
          }

          // Mientras espera la respuesta muestra un indicador de carga.
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
