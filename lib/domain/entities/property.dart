class Property {
  final int id;
  final String idPropiedad;
  final String direccion;
  final String tipoPropiedad;
  final int habitaciones;
  final int banos;
  final String? fotosPropiedad;
  final String titulo;
  final String descripcion;
  final DateTime createdAt;
  final String idArrendador;

  const Property({
    required this.id,
    required this.idPropiedad,
    required this.direccion,
    required this.tipoPropiedad,
    required this.habitaciones,
    required this.banos,
    this.fotosPropiedad,
    required this.titulo,
    required this.descripcion,
    required this.createdAt,
    required this.idArrendador,
  });
}
