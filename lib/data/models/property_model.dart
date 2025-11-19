import '../../domain/entities/property.dart';

class PropertyModel extends Property {
  const PropertyModel({
    required super.id,
    required super.idPropiedad,
    required super.direccion,
    required super.tipoPropiedad,
    required super.habitaciones,
    required super.banos,
    super.fotosPropiedad,
    required super.titulo,
    required super.descripcion,
    required super.createdAt,
    required super.idArrendador,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'],
      idPropiedad: json['id_propiedad'],
      direccion: json['direccion'],
      tipoPropiedad: json['tipo_propiedad'],
      habitaciones: json['habitaciones'],
      banos: json['baños'],
      fotosPropiedad: json['fotos_propiedad'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      createdAt: DateTime.parse(json['created_at']),
      idArrendador: json['id_arrendador'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_propiedad': idPropiedad,
      'direccion': direccion,
      'tipo_propiedad': tipoPropiedad,
      'habitaciones': habitaciones,
      'baños': banos,
      'fotos_propiedad': fotosPropiedad,
      'titulo': titulo,
      'descripcion': descripcion,
      'created_at': createdAt.toIso8601String(),
      'id_arrendador': idArrendador,
    };
  }
}
