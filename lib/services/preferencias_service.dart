import 'package:shared_preferences/shared_preferences.dart';

// Servicio que centraliza el manejo de SharedPreferences para guardar
// preferencias simples del usuario (sesión activa, correo recordado, etc.).
class PreferenciasService {
  static const _kCorreoSesion = 'correo_sesion';   // Correo del usuario logueado.
  static const _kRecordarme   = 'recordarme';      // Bandera para recordar la sesión.
  static const _kTemaOscuro   = 'tema_oscuro';     // Preferencia visual.

  // Guarda el correo del usuario que inició sesión.
  Future<void> guardarSesion(String correo, {required bool recordar}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCorreoSesion, correo);
    await prefs.setBool(_kRecordarme, recordar);
  }

  // Devuelve el correo guardado si el usuario marcó "recordarme".
  Future<String?> obtenerSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final recordar = prefs.getBool(_kRecordarme) ?? false;
    if (!recordar) return null;
    return prefs.getString(_kCorreoSesion);
  }

  // Limpia la sesión cuando el usuario cierra sesión.
  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCorreoSesion);
    await prefs.setBool(_kRecordarme, false);
  }

  // Lee/guarda preferencia de tema oscuro.
  Future<bool> obtenerTemaOscuro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kTemaOscuro) ?? false;
  }

  Future<void> guardarTemaOscuro(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kTemaOscuro, valor);
  }
}
