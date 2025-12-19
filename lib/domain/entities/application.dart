class Application {
  final String id;
  final String arrendatarioId;
  final String arrendadorId;
  final String propiedadId;
  final String estado;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Campos opcionales para cuando se hace join
  final String? nombreArrendatario;
  final String? tituloPropiedad;
  final String? direccionPropiedad;
  final double? precioRenta;

  const Application({
    required this.id,
    required this.arrendatarioId,
    required this.arrendadorId,
    required this.propiedadId,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    this.nombreArrendatario,
    this.tituloPropiedad,
    this.direccionPropiedad,
    this.precioRenta,
  });
}
