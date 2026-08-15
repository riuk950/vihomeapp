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
