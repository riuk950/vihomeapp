import '../../domain/entities/amenidad.dart';

class AmenidadModel extends Amenidad {
  const AmenidadModel({
    required super.idAmenidad,
    required super.logo,
  });

  factory AmenidadModel.fromJson(Map<String, dynamic> json) {
    return AmenidadModel(
      idAmenidad: json['id_amenidad'] ?? '',
      logo: json['logo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_amenidad': idAmenidad,
      'logo': logo,
    };
  }
}
