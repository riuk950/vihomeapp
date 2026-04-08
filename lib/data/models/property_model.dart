import '../../domain/entities/property.dart';

class PropertyModel extends Property {
  const PropertyModel({
    required super.id,
    required super.arrendadorId,
    required super.tipoPropiedad,
    required super.titulo,
    required super.direccion,
    required super.ciudad,
    required super.descripcion,
    required super.precio,
    super.precioRenta,
    super.precioVenta,
    required super.habitaciones,
    required super.banos,
    required super.metrosCuadrados,
    required super.lat,
    required super.lng,
    required super.publicado,
    required super.estado,
    required super.createdAt,
    required super.updatedAt,
    super.fotos,
    super.amenidades,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'],
      arrendadorId: json['arrendador_id'],
      tipoPropiedad: json['tipo_propiedad'],
      titulo: json['titulo'],
      direccion: json['direccion'],
      ciudad: json['ciudad'],
      descripcion: json['descripcion'],
      precio: (json['precio'] as num).toDouble(),
      precioRenta: json['precio_renta'] != null
          ? (json['precio_renta'] as num).toDouble()
          : null,
      precioVenta: json['precio_venta'] != null
          ? (json['precio_venta'] as num).toDouble()
          : null,
      habitaciones: json['habitaciones'],
      banos: json['banos'],
      metrosCuadrados: (json['metros_cuadrados'] as num).toDouble(),
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      publicado: json['publicado'],
      estado: json['estado'] ?? 'Disponible', // Default if missing
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      fotos: json['fotos'] != null ? List<String>.from(json['fotos']) : [],
      amenidades: json['amenidades'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arrendador_id': arrendadorId,
      'tipo_propiedad': tipoPropiedad,
      'titulo': titulo,
      'direccion': direccion,
      'ciudad': ciudad,
      'descripcion': descripcion,
      'precio': precio,
      'precio_renta': precioRenta,
      'precio_venta': precioVenta,
      'habitaciones': habitaciones,
      'banos': banos,
      'metros_cuadrados': metrosCuadrados,
      'lat': lat,
      'lng': lng,
      'publicado': publicado,
      'estado': estado,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'fotos': fotos,
      'amenidades': amenidades,
    };
  }
}
