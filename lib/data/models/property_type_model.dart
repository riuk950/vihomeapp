import '../../domain/entities/property_type.dart';

class PropertyTypeModel extends PropertyType {
  const PropertyTypeModel({
    required super.nombre,
  });

  factory PropertyTypeModel.fromJson(Map<String, dynamic> json) {
    return PropertyTypeModel(
      nombre: json['propiedad'] ?? '',
    );
  }
}
