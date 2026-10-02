import 'tenant.dart';

class Landlord {
  final String id;
  final String primerNombre;
  final String? segundoNombre;
  final String primerApellido;
  final String? segundoApellido;
  final String documento;
  final String direccionContacto;
  final String tipoDocumento;
  final String telefonoContacto;
  final String? fcmToken;

  const Landlord({
    required this.id,
    required this.primerNombre,
    this.segundoNombre,
    required this.primerApellido,
    this.segundoApellido,
    required this.documento,
    required this.direccionContacto,
    required this.tipoDocumento,
    required this.telefonoContacto,
    this.fcmToken,
  });

  String get nombre => '$primerNombre $primerApellido';

  Landlord copyWith({
    String? id,
    String? primerNombre,
    String? segundoNombre,
    String? primerApellido,
    String? segundoApellido,
    String? documento,
    String? direccionContacto,
    String? tipoDocumento,
    String? telefonoContacto,
    String? fcmToken,
  }) {
    return Landlord(
      id: id ?? this.id,
      primerNombre: primerNombre ?? this.primerNombre,
      segundoNombre: segundoNombre ?? this.segundoNombre,
      primerApellido: primerApellido ?? this.primerApellido,
      segundoApellido: segundoApellido ?? this.segundoApellido,
      documento: documento ?? this.documento,
      direccionContacto: direccionContacto ?? this.direccionContacto,
      tipoDocumento: tipoDocumento ?? this.tipoDocumento,
      telefonoContacto: telefonoContacto ?? this.telefonoContacto,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  Tenant toTenant() {
    return Tenant(
      id: id,
      primerNombre: primerNombre,
      segundoNombre: segundoNombre,
      primerApellido: primerApellido,
      segundoApellido: segundoApellido,
      documento: documento,
      direccionContacto: direccionContacto,
      tipoDocumento: tipoDocumento,
      telefonoContacto: telefonoContacto,
      fcmToken: fcmToken,
    );
  }

  factory Landlord.fromTenant(Tenant tenant) {
    return Landlord(
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

  List<Object?> get props => [
        id,
        primerNombre,
        segundoNombre,
        primerApellido,
        segundoApellido,
        documento,
        direccionContacto,
        tipoDocumento,
        telefonoContacto,
        fcmToken,
      ];
}
