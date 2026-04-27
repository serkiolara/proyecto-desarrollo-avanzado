import 'package:flutter/material.dart';
import 'services/preferencias_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>(); // Llave del Form para poder validar todos los campos juntos.

  // Los controllers permiten leer el texto escrito por el usuario en cada campo.
  final correoController     = TextEditingController();
  final contrasenaController = TextEditingController();

  bool _ocultarContrasena = true;  // Controla si la contraseña se muestra o se oculta.
  bool _recordarme        = true;  // Persistir sesión con SharedPreferences.
  bool _cargando          = false; // Estado de animación del botón.

  // Controlador de animación para la entrada de la pantalla (FadeTransition + Slide).
  late final AnimationController _animController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  final _prefs = PreferenciasService();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    correoController.dispose();
    contrasenaController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _intentarLogin() async {
    final valido = _formKey.currentState!.validate(); // Valida todos los campos del Form al mismo tiempo.
    if (!valido) return;

    setState(() => _cargando = true);

    // Pequeña pausa simulada para que se aprecie la animación del botón.
    await Future.delayed(const Duration(milliseconds: 600));

    final correo = correoController.text.trim();

    // Persiste la sesión si el usuario lo pidió.
    await _prefs.guardarSesion(correo, recordar: _recordarme);

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: {'correo': correo},
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form( // El widget Form agrupa los TextFormField y ejecuta sus validaciones al llamar validate.
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    // Logo / Hero superior con Stack.
                    SizedBox(
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 140, height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [cs.primary, cs.tertiary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          const Icon(Icons.movie_filter, size: 72, color: Colors.white),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'MisPelis',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tu registro personal de películas',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Correo
                    TextFormField(
                      controller: correoController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Correo obligatorio';
                        if (!value.contains('@'))                    return 'Correo inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Contraseña
                    TextFormField(
                      controller: contrasenaController,
                      obscureText: _ocultarContrasena,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_ocultarContrasena ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _ocultarContrasena = !_ocultarContrasena),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Contraseña obligatoria';
                        if (value.trim().length < 6)               return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // Recordarme (SharedPreferences).
                    Row(
                      children: [
                        Checkbox(
                          value: _recordarme,
                          onChanged: (v) => setState(() => _recordarme = v ?? false),
                        ),
                        const Text('Recordar mi sesión'),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Botón con AnimatedContainer (cambia de tamaño y color durante la carga).
                    GestureDetector(
                      onTap: _cargando ? null : _intentarLogin,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                        height: 52,
                        width: _cargando ? 52 : double.infinity,
                        decoration: BoxDecoration(
                          color: _cargando ? cs.primaryContainer : cs.primary,
                          borderRadius: BorderRadius.circular(_cargando ? 26 : 12),
                          boxShadow: [
                            BoxShadow(
                              color: cs.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: _cargando
                            ? const SizedBox(
                                height: 24, width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Entrar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
