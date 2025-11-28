import '../../domain/entities/landlord.dart';

class LandlordModel extends Landlord {
  const LandlordModel({
    required super.id,
    required super.primerNombre,
    super.segundoNombre,
    required super.primerApellido,
    super.segundoApellido,
    required super.documento,
    required super.direccionContacto,
    required super.tipoDocumento,
    required super.telefonoContacto,
  });

  factory LandlordModel.fromJson(Map<String, dynamic> json) {
    return LandlordModel(
      id: json['id'],
      primerNombre: json['primer_nombre'],
      segundoNombre: json['segundo_nombre'],
      primerApellido: json['primer_apellido'],
      segundoApellido: json['segundo_apellido'],
      documento: json['documento'],
      direccionContacto: json['direccion_contacto'],
      tipoDocumento: json['tipo_documento'],
      telefonoContacto: json['telefono_contacto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'primer_nombre': primerNombre,
      'segundo_nombre': segundoNombre,
      'primer_apellido': primerApellido,
      'segundo_apellido': segundoApellido,
      'documento': documento,
      'direccion_contacto': direccionContacto,
      'tipo_documento': tipoDocumento,
      'telefono_contacto': telefonoContacto,
    };
  }

  factory LandlordModel.fromEntity(Landlord landlord) {
    return LandlordModel(
      id: landlord.id,
      primerNombre: landlord.primerNombre,
      segundoNombre: landlord.segundoNombre,
      primerApellido: landlord.primerApellido,
      segundoApellido: landlord.segundoApellido,
      documento: landlord.documento,
      direccionContacto: landlord.direccionContacto,
      tipoDocumento: landlord.tipoDocumento,
      telefonoContacto: landlord.telefonoContacto,
    );
  }
}
