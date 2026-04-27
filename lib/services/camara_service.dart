import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

// Servicio que encapsula la captura de imágenes desde la cámara o la galería.
// Las imágenes se copian al directorio de documentos de la app para que la
// ruta sobreviva a reinicios del dispositivo.
class CamaraService {
  final ImagePicker _picker = ImagePicker();

  // Toma una foto con la cámara y devuelve la ruta del archivo guardado
  // en el almacenamiento privado de la app. Devuelve null si el usuario cancela.
  Future<String?> tomarFoto() => _capturar(ImageSource.camera);

  // Permite elegir una imagen de la galería.
  Future<String?> elegirDeGaleria() => _capturar(ImageSource.gallery);

  Future<String?> _capturar(ImageSource source) async {
    final XFile? archivo = await _picker.pickImage(
      source: source,
      imageQuality: 75,        // Comprime para no llenar el dispositivo.
      maxWidth: 1600,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (archivo == null) return null;
    return _persistir(archivo);
  }

  // Copia el archivo temporal a documentos para que la ruta sea estable.
  Future<String> _persistir(XFile origen) async {
    final dirDocs = await getApplicationDocumentsDirectory();
    final dirFotos = Directory('${dirDocs.path}/peliculas');
    if (!await dirFotos.exists()) {
      await dirFotos.create(recursive: true);
    }
    final ts = DateTime.now().millisecondsSinceEpoch;
    final ext = _extension(origen.path);
    final destino = '${dirFotos.path}/pelicula_$ts$ext';
    final copia = await File(origen.path).copy(destino);
    return copia.path;
  }

  String _extension(String ruta) {
    final i = ruta.lastIndexOf('.');
    return (i >= 0 && i > ruta.lastIndexOf('/')) ? ruta.substring(i) : '.jpg';
  }
}
