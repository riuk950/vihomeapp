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
    super.empresa,
    super.cargo,
    super.tiempoEmpleo,
    super.ingresosMensuales,
    super.otrosIngresos,
    super.documentoUrl,
    super.refPersonales,
    super.nombreArrendatario,
    super.tituloPropiedad,
    super.direccionPropiedad,
    super.precioRenta,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    // Intentar extraer datos anidados si vienen del join
    String? nombreArrendatario;
    if (json['arrendatario'] != null && json['arrendatario'] is Map) {
      final userData = json['arrendatario'];
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

    // Parsear referencias personales
    List<PersonalReference>? refPersonales;
    if (json['ref_personales'] != null && json['ref_personales'] is List) {
      refPersonales = (json['ref_personales'] as List)
          .map(
            (ref) => PersonalReference(
              nombre: ref['nombre'] ?? '',
              telefono: ref['telefono'] ?? '',
              relacion: ref['relacion'] ?? '',
            ),
          )
          .toList();
    }

    return ApplicationModel(
      id: json['id'],
      arrendatarioId: json['arrendatario_id'],
      arrendadorId: json['arrendador_id'],
      propiedadId: json['propiedad_id'],
      estado: json['estado'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      empresa: json['empresa']?.toString(),
      cargo: json['cargo']?.toString(),
      tiempoEmpleo: json['tiempo_empleo']?.toString(),
      ingresosMensuales: json['ingresos_mensuales']?.toString(),
      otrosIngresos: json['otros_ingresos']?.toString(),
      documentoUrl: json['documento_url']?.toString(),
      refPersonales: refPersonales,
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
      if (empresa != null) 'empresa': empresa,
      if (cargo != null) 'cargo': cargo,
      if (tiempoEmpleo != null) 'tiempo_empleo': tiempoEmpleo,
      if (ingresosMensuales != null) 'ingresos_mensuales': ingresosMensuales,
      if (otrosIngresos != null) 'otros_ingresos': otrosIngresos,
      if (documentoUrl != null) 'documento_url': documentoUrl,
      if (refPersonales != null)
        'ref_personales': refPersonales!
            .map(
              (ref) => {
                'nombre': ref.nombre,
                'telefono': ref.telefono,
                'relacion': ref.relacion,
              },
            )
            .toList(),
    };
  }

  // Método específico para crear una nueva solicitud (sin id, created_at, updated_at)
  Map<String, dynamic> toJsonCreate() {
    return {
      'arrendatario_id': arrendatarioId,
      'arrendador_id': arrendadorId,
      'propiedad_id': propiedadId,
      'estado': estado,
      if (empresa != null) 'empresa': empresa,
      if (cargo != null) 'cargo': cargo,
      if (tiempoEmpleo != null) 'tiempo_empleo': tiempoEmpleo,
      if (ingresosMensuales != null) 'ingresos_mensuales': ingresosMensuales,
      if (otrosIngresos != null) 'otros_ingresos': otrosIngresos,
      if (documentoUrl != null) 'documento_url': documentoUrl,
      if (refPersonales != null)
        'ref_personales': refPersonales!
            .map(
              (ref) => {
                'nombre': ref.nombre,
                'telefono': ref.telefono,
                'relacion': ref.relacion,
              },
            )
            .toList(),
    };
  }
}
