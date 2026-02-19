class Project {
  final String id;
  final String constructoraId;
  final String tipoPropiedad;
  final double precioDesde;
  final double precioHasta;
  final int habitaciones;
  final int banos;
  final double area;
  final String descripcion;
  final String? videoUrl;
  final String ubicacionPrincipal;
  final double lat;
  final double lng;
  final int estrato;
  final String estado;
  final int parqueaderos;
  final bool financiacion;
  final double coutaInicial;
  final int cantidadPisos;
  final bool aplicaSubsidio;
  final DateTime? fechaFinalizacion;
  final Map<String, dynamic>? caracteristicas;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Project({
    required this.id,
    required this.constructoraId,
    required this.tipoPropiedad,
    required this.precioDesde,
    required this.precioHasta,
    required this.habitaciones,
    required this.banos,
    required this.area,
    required this.descripcion,
    this.videoUrl,
    required this.ubicacionPrincipal,
    required this.lat,
    required this.lng,
    required this.estrato,
    required this.estado,
    required this.parqueaderos,
    required this.financiacion,
    required this.coutaInicial,
    required this.cantidadPisos,
    required this.aplicaSubsidio,
    this.fechaFinalizacion,
    this.caracteristicas,
    required this.createdAt,
    required this.updatedAt,
  });
}
