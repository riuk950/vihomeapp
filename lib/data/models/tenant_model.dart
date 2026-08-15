import '../../domain/entities/tenant.dart';

class TenantModel extends Tenant {
  const TenantModel({
    required super.id,
    required super.primerNombre,
    super.segundoNombre,
    required super.primerApellido,
    super.segundoApellido,
    required super.documento,
    required super.direccionContacto,
    required super.tipoDocumento,
    required super.telefonoContacto,
    super.fcmToken,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id'] as String,
      primerNombre: json['primer_nombre'] as String,
      segundoNombre: json['segundo_nombre'] as String?,
      primerApellido: json['primer_apellido'] as String,
      segundoApellido: json['segundo_apellido'] as String?,
      documento: json['documento'],
      direccionContacto: json['direccion_contacto'] as String,
      tipoDocumento: json['tipo_documento'] as String,
      telefonoContacto: json['telefono_contacto'] as String,
      fcmToken: json['fcm_token'] as String?,
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
      'fcm_token': fcmToken,
    };
  }

  factory TenantModel.fromEntity(Tenant tenant) {
    return TenantModel(
      id: tenant.id,
      primerNombre: tenant.primerNombre,
      segundoNombre: tenant.segundoNombre,
      primerApellido: tenant.primerApellido,
      segundoApellido: tenant.segundoApellido,
      documento: tenant.documento,
      direccionContacto: tenant.direccionContacto,
      tipoDocumento: tenant.tipoDocumento,
      telefonoContacto: tenant.telefonoContacto,
      fcmToken: tenant.fcmToken,
    );
  }
}
