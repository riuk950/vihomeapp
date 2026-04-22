class Constructora {
  final String id;
  final String nombre;
  final String? logoUrl;
  final String nit;
  final String? departamento;
  final String? ciudad;
  final String? direccion;
  final String? telefonoFijo;
  final String? whatsapp;
  final String? sitioWeb;
  final String? correo;

  const Constructora({
    required this.id,
    required this.nombre,
    this.logoUrl,
    required this.nit,
    this.departamento,
    this.ciudad,
    this.direccion,
    this.telefonoFijo,
    this.whatsapp,
    this.sitioWeb,
    this.correo,
  });

  List<Object?> get props => [
        id,
        nombre,
        logoUrl,
        nit,
        departamento,
        ciudad,
        direccion,
        telefonoFijo,
        whatsapp,
        sitioWeb,
        correo,
      ];
}
