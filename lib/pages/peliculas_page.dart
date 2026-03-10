import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/pelicula.dart';

class PeliculasPage extends StatelessWidget {

  final ApiService apiService = ApiService();

  PeliculasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de películas')),

      body: FutureBuilder<List<Pelicula>>(
        future: apiService.obtenerPeliculas(),

        builder: (context, snapshot) {
          // snapshot contiene los datos recibidos, el error si ocurrió, y el estado de carga.

          if (snapshot.hasData) { // La API ya respondió y hay datos disponibles.
            List<Pelicula> peliculas = snapshot.data!; // El valor no es null.

            // ListView.builder crea los elementos solo cuando se necesitan al hacer scroll.
            return ListView.builder(
              itemCount: peliculas.length,
              itemBuilder: (context, index) {

                final pelicula = peliculas[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: Image.network( // Carga la imagen del póster desde la URL que regresa la API.
                      pelicula.imageUrl,
                      width: 50,
                      fit: BoxFit.cover, // Recorta la imagen para que llene el espacio sin deformarse.
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.movie); // Si la imagen falla, muestra el icono de película.
                      },
                    ),
                    title: Text(pelicula.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(pelicula.description),
                        const SizedBox(height: 4),
                        Text('${pelicula.genre} · ${pelicula.year}'),
                        Text('Estrellas: ${pelicula.stars}'),
                      ],
                    ),
                  ),
                );

              },
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Error al cargar películas'),
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
