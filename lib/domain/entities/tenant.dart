class Tenant {
  final String id;
  final String primerNombre;
  final String? segundoNombre;
  final String primerApellido;
  final String? segundoApellido;
  final int documento;
  final String direccionContacto;
  final String tipoDocumento;
  final String telefonoContacto;
  final String? fcmToken;

  const Tenant({
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
