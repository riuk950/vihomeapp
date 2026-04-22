class PersonalReference {
  final String nombre;
  final String telefono;
  final String relacion;

  const PersonalReference({
    required this.nombre,
    required this.telefono,
    required this.relacion,
  });
}

class Application {
  final String id;
  final String arrendatarioId;
  final String arrendadorId;
  final String propiedadId;
  final String estado;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Información laboral y financiera
  final String? empresa;
  final String? cargo;
  final String? tiempoEmpleo;
  final String? ingresosMensuales;
  final String? otrosIngresos;
  final String? documentoUrl;
  final List<PersonalReference>? refPersonales;

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
    this.empresa,
    this.cargo,
    this.tiempoEmpleo,
    this.ingresosMensuales,
    this.otrosIngresos,
    this.documentoUrl,
    this.refPersonales,
    this.nombreArrendatario,
    this.tituloPropiedad,
    this.direccionPropiedad,
    this.precioRenta,
  });

  Application copyWith({
    String? id,
    String? arrendatarioId,
    String? arrendadorId,
    String? propiedadId,
    String? estado,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? empresa,
    String? cargo,
    String? tiempoEmpleo,
    String? ingresosMensuales,
    String? otrosIngresos,
    String? documentoUrl,
    List<PersonalReference>? refPersonales,
    String? nombreArrendatario,
    String? tituloPropiedad,
    String? direccionPropiedad,
    double? precioRenta,
  }) {
    return Application(
      id: id ?? this.id,
      arrendatarioId: arrendatarioId ?? this.arrendatarioId,
      arrendadorId: arrendadorId ?? this.arrendadorId,
      propiedadId: propiedadId ?? this.propiedadId,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      empresa: empresa ?? this.empresa,
      cargo: cargo ?? this.cargo,
      tiempoEmpleo: tiempoEmpleo ?? this.tiempoEmpleo,
      ingresosMensuales: ingresosMensuales ?? this.ingresosMensuales,
      otrosIngresos: otrosIngresos ?? this.otrosIngresos,
      documentoUrl: documentoUrl ?? this.documentoUrl,
      refPersonales: refPersonales ?? this.refPersonales,
      nombreArrendatario: nombreArrendatario ?? this.nombreArrendatario,
      tituloPropiedad: tituloPropiedad ?? this.tituloPropiedad,
      direccionPropiedad: direccionPropiedad ?? this.direccionPropiedad,
      precioRenta: precioRenta ?? this.precioRenta,
    );
  }
}
