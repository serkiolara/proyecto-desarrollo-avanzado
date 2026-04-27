import 'package:hive/hive.dart';

// Modelo que representa una película que el usuario ya vio,
// con su calificación personal y comentarios. Se persiste con Hive.
//
// Se implementa el TypeAdapter de forma manual para no depender de
// build_runner / hive_generator y mantener el proyecto simple.
class PeliculaVista extends HiveObject {
  String titulo;
  String genero;
  int anio;
  double calificacion; // 0.0 a 5.0 (estrellas).
  String comentario;
  DateTime fechaRegistro;
  String? imagenUrl;       // Poster del catálogo (URL remota).
  String? rutaFotoLocal;   // Foto tomada con la cámara o galería (path local).
  double? latitud;         // GPS.
  double? longitud;        // GPS.
  String? lugar;           // Dirección legible (geocoding inverso).

  PeliculaVista({
    required this.titulo,
    required this.genero,
    required this.anio,
    required this.calificacion,
    required this.comentario,
    required this.fechaRegistro,
    this.imagenUrl,
    this.rutaFotoLocal,
    this.latitud,
    this.longitud,
    this.lugar,
  });
}

// TypeAdapter para que Hive sepa cómo serializar/deserializar PeliculaVista.
class PeliculaVistaAdapter extends TypeAdapter<PeliculaVista> {
  @override
  final int typeId = 1; // Identificador único del tipo dentro de la app.

  @override
  PeliculaVista read(BinaryReader reader) {
    final numCampos = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numCampos; i++) reader.readByte(): reader.read(),
    };
    return PeliculaVista(
      titulo:        fields[0] as String,
      genero:        fields[1] as String,
      anio:          fields[2] as int,
      calificacion:  fields[3] as double,
      comentario:    fields[4] as String,
      fechaRegistro: fields[5] as DateTime,
      imagenUrl:     fields[6] as String?,
      rutaFotoLocal: fields[7] as String?,
      latitud:       fields[8] as double?,
      longitud:      fields[9] as double?,
      lugar:         fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PeliculaVista obj) {
    writer
      ..writeByte(11) // Número de campos.
      ..writeByte(0)..write(obj.titulo)
      ..writeByte(1)..write(obj.genero)
      ..writeByte(2)..write(obj.anio)
      ..writeByte(3)..write(obj.calificacion)
      ..writeByte(4)..write(obj.comentario)
      ..writeByte(5)..write(obj.fechaRegistro)
      ..writeByte(6)..write(obj.imagenUrl)
      ..writeByte(7)..write(obj.rutaFotoLocal)
      ..writeByte(8)..write(obj.latitud)
      ..writeByte(9)..write(obj.longitud)
      ..writeByte(10)..write(obj.lugar);
  }
}
