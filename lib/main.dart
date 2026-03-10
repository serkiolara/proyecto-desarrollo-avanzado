import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'pages/usuarios_page.dart';
import 'pages/peliculas_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proyecto Desarrollo Avanzado',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/', // La ruta inicial es el login.
      routes: { // Mapa de rutas nombradas de la aplicación.
        '/':         (context) => const LoginPage(),
        '/home':     (context) => const HomePage(),
        '/usuarios':  (context) => UsuariosPage(),
        '/peliculas': (context) => PeliculasPage(),
      },
    );
  }
}
