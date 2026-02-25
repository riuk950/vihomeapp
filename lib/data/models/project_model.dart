import '../../domain/entities/project.dart';

class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.constructoraId,
    required super.tipoPropiedad,
    required super.precioDesde,
    required super.precioHasta,
    required super.habitaciones,
    required super.banos,
    required super.area,
    required super.descripcion,
    super.videoUrl,
    required super.ubicacionPrincipal,
    required super.lat,
    required super.lng,
    required super.estrato,
    required super.estado,
    required super.parqueaderos,
    required super.financiacion,
    required super.coutaInicial,
    required super.cantidadPisos,
    required super.aplicaSubsidio,
    super.fechaFinalizacion,
    super.caracteristicas,
    required super.fotos,
    super.amenidades,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      constructoraId: json['constructora_id'] as String? ?? '',
      tipoPropiedad: json['tipo_propiedad'] as String? ?? '',
      precioDesde: (json['precio_desde'] as num?)?.toDouble() ?? 0.0,
      precioHasta: (json['precio_hasta'] as num?)?.toDouble() ?? 0.0,
      habitaciones: (json['habitaciones'] as num?)?.toInt() ?? 0,
      banos: (json['baños'] as num?)?.toInt() ?? 0,
      area: (json['area'] as num?)?.toDouble() ?? 0.0,
      descripcion: json['descripcion'] as String? ?? '',
      videoUrl: json['video_url'] as String?,
      ubicacionPrincipal: json['ubicacion_principal'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      estrato: (json['estrato'] as num?)?.toInt() ?? 0,
      estado: json['estado'] as String? ?? '',
      parqueaderos: (json['parqueaderos'] as num?)?.toInt() ?? 0,
      financiacion: json['financiacion'] as bool? ?? false,
      coutaInicial: (json['couta_inicial'] as num?)?.toDouble() ?? 0.0,
      cantidadPisos: (json['cantidad_pisos'] as num?)?.toInt() ?? 0,
      aplicaSubsidio: json['aplica_subsidio'] as bool? ?? false,
      fechaFinalizacion: json['fecha_finalizacion'] != null
          ? DateTime.tryParse(json['fecha_finalizacion'] as String)
          : null,
      caracteristicas: json['caracteristicas'] as Map<String, dynamic>?,
      fotos:
          (json['fotos'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      amenidades: json['amenidades'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
