import 'package:vihomeapp/domain/entities/application_context_data.dart';

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

  // Campos opcionales para cuando se hace join / snapshots de contacto (Fase 2)
  final String? nombreArrendatario;
  final String? telefonoArrendatario;
  final String? nombreArrendador;
  final String? telefonoArrendador;
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
    this.datosContextuales,
    this.nombreArrendatario,
    this.telefonoArrendatario,
    this.nombreArrendador,
    this.telefonoArrendador,
    this.tituloPropiedad,
    this.direccionPropiedad,
    this.precioRenta,
  });

  // Datos contextuales según el tipo de inmueble [RF-13.2]
  final ApplicationContextData? datosContextuales;

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
    ApplicationContextData? datosContextuales,
    String? nombreArrendatario,
    String? telefonoArrendatario,
    String? nombreArrendador,
    String? telefonoArrendador,
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
      datosContextuales: datosContextuales ?? this.datosContextuales,
      nombreArrendatario: nombreArrendatario ?? this.nombreArrendatario,
      telefonoArrendatario: telefonoArrendatario ?? this.telefonoArrendatario,
      nombreArrendador: nombreArrendador ?? this.nombreArrendador,
      telefonoArrendador: telefonoArrendador ?? this.telefonoArrendador,
      tituloPropiedad: tituloPropiedad ?? this.tituloPropiedad,
      direccionPropiedad: direccionPropiedad ?? this.direccionPropiedad,
      precioRenta: precioRenta ?? this.precioRenta,
    );
  }
}
