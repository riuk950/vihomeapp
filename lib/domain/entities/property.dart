class Property {
  final String id;
  final String arrendadorId;
  final String tipoPropiedad;
  final String titulo;
  final String direccion;
  final String ciudad;
  final String descripcion;
  final double precio;
  final double? precioRenta;
  final double? precioVenta;
  final int habitaciones;
  final int banos;
  final double metrosCuadrados;
  final double lat;
  final double lng;
  final bool publicado;
  final String estado;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> fotos;
  final List<dynamic>? amenidades;

  const Property({
    required this.id,
    required this.arrendadorId,
    required this.tipoPropiedad,
    required this.titulo,
    required this.direccion,
    required this.ciudad,
    required this.descripcion,
    required this.precio,
    this.precioRenta,
    this.precioVenta,
    required this.habitaciones,
    required this.banos,
    required this.metrosCuadrados,
    required this.lat,
    required this.lng,
    required this.publicado,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    this.fotos = const [],
    this.amenidades,
  });
}
