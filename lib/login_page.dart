import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _formKey = GlobalKey<FormState>(); // Llave del Form para poder validar todos los campos juntos.

  // Los controllers permiten leer el texto escrito por el usuario en cada campo.
  final correoController    = TextEditingController();
  final contrasenaController = TextEditingController();

  bool _ocultarContrasena = true; // Controla si la contraseña se muestra o se oculta.

  @override
  void dispose() {
    correoController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form( // El widget Form agrupa los TextFormField y ejecuta sus validaciones al llamar validate.
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Correo
              TextFormField( // Usa correoController para leer el valor.
                controller: correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Correo obligatorio';
                  }
                  if (!value.contains('@')) {
                    return 'Correo inválido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Contraseña
              TextFormField( // Usa contrasenaController para leer el valor.
                controller: contrasenaController,
                obscureText: _ocultarContrasena,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton( // Botón para mostrar u ocultar la contraseña.
                    icon: Icon(
                      _ocultarContrasena ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _ocultarContrasena = !_ocultarContrasena;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Contraseña obligatoria';
                  }
                  if (value.trim().length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {

                  // Ejecuta validaciones
                  final valido = _formKey.currentState!.validate(); // Valida todos los campos del Form al mismo tiempo.

                  if (!valido) return;

                  // Si todo está correcto, navega a la pantalla principal
                  Navigator.pushReplacementNamed( // Navega a '/home' y envía el correo como argumento.
                    context,
                    '/home',
                    arguments: {
                      'correo': correoController.text.trim(), // Se lee el controller para obtener el texto del campo.
                    },
                  );
                },
                child: const Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
