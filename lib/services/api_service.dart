import 'dart:convert'; // Permite usar json.decode para convertir texto JSON a objetos de Dart.
import 'package:http/http.dart' as http; // Paquete externo para hacer peticiones HTTP.
import '../models/usuario.dart';
import '../models/pelicula.dart';

// ApiService centraliza todas las llamadas a APIs externas de la aplicación.
class ApiService {

  // Método asíncrono que hace una petición GET y retorna una lista de Usuario.
  // async indica que el método puede pausarse mientras espera la respuesta de la red.
  Future<List<Usuario>> obtenerUsuarios() async {

    // await pausa la ejecución hasta recibir la respuesta; sin él el código seguiría sin esperar.
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/users'), // Uri.parse convierte el texto en una URL válida.
    );

    // statusCode 200 significa que la petición fue exitosa.
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body); // response.body contiene el JSON en texto; decode lo convierte en lista.
      return jsonResponse
          .map((usuario) => Usuario.fromJson(usuario)) // Convierte cada elemento del JSON en un objeto Usuario.
          .toList(); // Convierte el resultado del map en una List.
    } else {
      throw Exception('Error al cargar usuarios'); // Si el servidor respondió con error, lanza una excepción.
    }
  }

  // Método asíncrono que hace una petición GET y retorna una lista de Pelicula.
  // async indica que el método puede pausarse mientras espera la respuesta de la red.
  Future<List<Pelicula>> obtenerPeliculas() async {

    // await pausa la ejecución hasta recibir la respuesta; sin él el código seguiría sin esperar.
    final response = await http.get(
      Uri.parse('https://devsapihub.com/api-movies'), // Uri.parse convierte el texto en una URL válida.
    );

    // statusCode 200 significa que la petición fue exitosa.
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body); // response.body contiene el JSON en texto; decode lo convierte en lista.
      return jsonResponse
          .map((pelicula) => Pelicula.fromJson(pelicula)) // Convierte cada elemento del JSON en un objeto Pelicula.
          .toList(); // Convierte el resultado del map en una List.
    } else {
      throw Exception('Error al cargar películas'); // Si el servidor respondió con error, lanza una excepción.
    }
  }
}
