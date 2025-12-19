import 'package:vihomeapp/domain/entities/application.dart';

class ApplicationModel extends Application {
  const ApplicationModel({
    required super.id,
    required super.arrendatarioId,
    required super.arrendadorId,
    required super.propiedadId,
    required super.estado,
    required super.createdAt,
    required super.updatedAt,
    super.nombreArrendatario,
    super.tituloPropiedad,
    super.direccionPropiedad,
    super.precioRenta,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    // Intentar extraer datos anidados si vienen del join
    String? nombreArrendatario;
    if (json['arrendatario'] != null && json['arrendatario'] is Map) {
      // Ajustar según estructura de usuario, asumiendo metadata o campos directos
      // Por ahora placeholder o estructura común
      final userData = json['arrendatario'];
      // Esto depende de cómo se guarde el usuario (auth.users o tabla publica perfiles)
      // Asumiremos que si viene de un join a una tabla publica 'perfiles' o similar:
      nombreArrendatario = userData['nombre'] ?? userData['email'];
    }

    String? tituloPropiedad;
    String? direccionPropiedad;
    double? precioRenta;

    if (json['propiedades'] != null && json['propiedades'] is Map) {
      final propData = json['propiedades'];
      tituloPropiedad = propData['titulo'];
      direccionPropiedad = propData['direccion'];
      precioRenta = (propData['precio_renta'] as num?)?.toDouble();
    }

    return ApplicationModel(
      id: json['id'],
      arrendatarioId: json['arrendatario_id'],
      arrendadorId: json['arrendador_id'],
      propiedadId: json['propiedad_id'],
      estado: json['estado'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      nombreArrendatario: nombreArrendatario,
      tituloPropiedad: tituloPropiedad,
      direccionPropiedad: direccionPropiedad,
      precioRenta: precioRenta,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arrendatario_id': arrendatarioId,
      'arrendador_id': arrendadorId,
      'propiedad_id': propiedadId,
      'estado': estado,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
