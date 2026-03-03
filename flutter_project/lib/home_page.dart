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
        child: Text(
          'Bienvenido, $correo',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
