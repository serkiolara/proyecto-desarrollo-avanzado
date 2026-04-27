import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'pages/usuarios_page.dart';
import 'pages/peliculas_page.dart';
import 'pages/mis_peliculas_page.dart';
import 'pages/agregar_pelicula_page.dart';
import 'pages/mis_cines_page.dart';
import 'services/peliculas_repository.dart';
import 'services/preferencias_service.dart';

Future<void> main() async {
  // Asegura el binding antes de usar plataforma (Hive / SharedPreferences).
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Hive y registra el TypeAdapter de PeliculaVista.
  await PeliculasRepository.init();

  // Lee la preferencia de sesión guardada (si el usuario marcó "recordarme").
  final correoGuardado = await PreferenciasService().obtenerSesion();

  runApp(MyApp(correoGuardado: correoGuardado));
}

class MyApp extends StatelessWidget {
  final String? correoGuardado;
  const MyApp({super.key, this.correoGuardado});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MisPelis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      // Si hay sesión recordada, vamos directo a Home; si no, al Login.
      initialRoute: correoGuardado == null ? '/' : '/home',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/home':
            // Si la ruta inicial es /home (por sesión recordada),
            // los argumentos pueden ser null, así que los reconstruimos.
            final args = settings.arguments as Map<String, dynamic>? ??
                {'correo': correoGuardado ?? ''};
            return MaterialPageRoute(
              settings: RouteSettings(name: '/home', arguments: args),
              builder: (_) => const HomePage(),
            );
          case '/usuarios':
            return MaterialPageRoute(builder: (_) => UsuariosPage());
          case '/peliculas':
            return MaterialPageRoute(builder: (_) => PeliculasPage());
          case '/mis-peliculas':
            return MaterialPageRoute(builder: (_) => const MisPeliculasPage());
          case '/agregar-pelicula':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const AgregarPeliculaPage(),
            );
          case '/mis-cines':
            return MaterialPageRoute(builder: (_) => const MisCinesPage());
          default:
            return MaterialPageRoute(builder: (_) => const LoginPage());
        }
      },
    );
  }
}
