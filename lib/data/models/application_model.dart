import 'package:vihomeapp/data/models/application_context_data_model.dart';
import 'package:vihomeapp/domain/entities/application.dart';

class ApplicationModel extends Application {
  const ApplicationModel({
    required super.id,
    required super.arrendatarioId,
    required super.arrendadorId,
    required super.propiedadId,
    required super.estado,
    required super.createdAt,
    required super.updatedAt,
    super.empresa,
    super.cargo,
    super.tiempoEmpleo,
    super.ingresosMensuales,
    super.otrosIngresos,
    super.documentoUrl,
    super.refPersonales,
    super.datosContextuales,
    super.nombreArrendatario,
    super.telefonoArrendatario,
    super.nombreArrendador,
    super.telefonoArrendador,
    super.tituloPropiedad,
    super.direccionPropiedad,
    super.precioRenta,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    // Intentar extraer datos de arrendatario directos o desde join
    String? nombreArrendatario = json['nombre_arrendatario']?.toString();
    String? telefonoArrendatario = json['telefono_arrendatario']?.toString();
    if (json['arrendatario'] != null && json['arrendatario'] is Map) {
      final userData = json['arrendatario'];
      nombreArrendatario ??= userData['nombre']?.toString() ??
          userData['primer_nombre']?.toString() ??
          userData['email']?.toString();
      telefonoArrendatario ??= userData['telefono']?.toString() ??
          userData['telefono_contacto']?.toString();
    }

    // Intentar extraer datos de arrendador directos o desde join
    String? nombreArrendador = json['nombre_arrendador']?.toString();
    String? telefonoArrendador = json['telefono_arrendador']?.toString();
    if (json['arrendador'] != null && json['arrendador'] is Map) {
      final landlordData = json['arrendador'];
      nombreArrendador ??= landlordData['nombre']?.toString() ??
          landlordData['email']?.toString();
      telefonoArrendador ??= landlordData['telefono']?.toString() ??
          landlordData['telefono_contacto']?.toString();
    }

    // Intentar extraer datos de propiedad directos o desde join
    String? tituloPropiedad = json['titulo_propiedad']?.toString();
    String? direccionPropiedad = json['direccion_propiedad']?.toString();
    double? precioRenta = (json['precio_renta'] as num?)?.toDouble();

    if (json['propiedades'] != null && json['propiedades'] is Map) {
      final propData = json['propiedades'];
      tituloPropiedad ??= propData['titulo']?.toString();
      direccionPropiedad ??= propData['direccion']?.toString();
      precioRenta ??= (propData['precio_renta'] as num?)?.toDouble();
    }

    // Fallbacks defensivos para resiliencia (QA 1.10, QA 1.11, CL-15, CL-16)
    if (tituloPropiedad == null || tituloPropiedad.trim().isEmpty) {
      tituloPropiedad = 'Inmueble no disponible';
    }

    if (nombreArrendatario == null || nombreArrendatario.trim().isEmpty) {
      nombreArrendatario = 'Usuario no disponible';
    }

    if (nombreArrendador == null || nombreArrendador.trim().isEmpty) {
      nombreArrendador = 'Usuario no disponible';
    }

    // Parsear referencias personales
    List<PersonalReference>? refPersonales;
    if (json['ref_personales'] != null && json['ref_personales'] is List) {
      refPersonales = (json['ref_personales'] as List)
          .map(
            (ref) => PersonalReference(
              nombre: ref['nombre'] ?? '',
              telefono: ref['telefono'] ?? '',
              relacion: ref['relacion'] ?? '',
            ),
          )
          .toList();
    }

    // Parsear datos contextuales si existen
    final rawContext = json['datos_contextuales'];
    final datosContextuales = rawContext is Map<String, dynamic>
        ? ApplicationContextDataModel.fromJson(rawContext)
        : null;

    final String rawEstado = json['estado']?.toString() ?? 'desconocido';
    final String estado = rawEstado.trim().isNotEmpty ? rawEstado.trim() : 'desconocido';

    DateTime createdAt;
    try {
      createdAt = json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now();
    } catch (_) {
      createdAt = DateTime.now();
    }

    DateTime updatedAt;
    try {
      updatedAt = json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now();
    } catch (_) {
      updatedAt = DateTime.now();
    }

    return ApplicationModel(
      id: json['id']?.toString() ?? '',
      arrendatarioId: json['arrendatario_id']?.toString() ?? '',
      arrendadorId: json['arrendador_id']?.toString() ?? '',
      propiedadId: json['propiedad_id']?.toString() ?? '',
      estado: estado,
      createdAt: createdAt,
      updatedAt: updatedAt,
      empresa: json['empresa']?.toString(),
      cargo: json['cargo']?.toString(),
      tiempoEmpleo: json['tiempo_empleo']?.toString(),
      ingresosMensuales: json['ingresos_mensuales']?.toString(),
      otrosIngresos: json['otros_ingresos']?.toString(),
      documentoUrl: json['documento_url']?.toString(),
      refPersonales: refPersonales,
      datosContextuales: datosContextuales,
      nombreArrendatario: nombreArrendatario,
      telefonoArrendatario: telefonoArrendatario,
      nombreArrendador: nombreArrendador,
      telefonoArrendador: telefonoArrendador,
      tituloPropiedad: tituloPropiedad,
      direccionPropiedad: direccionPropiedad,
      precioRenta: precioRenta,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arrendatario_id': arrendatarioId,
      'arrendador_id': arrendadorId,
      'propiedad_id': propiedadId,
      'estado': estado,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (empresa != null) 'empresa': empresa,
      if (cargo != null) 'cargo': cargo,
      if (tiempoEmpleo != null) 'tiempo_empleo': tiempoEmpleo,
      if (ingresosMensuales != null) 'ingresos_mensuales': ingresosMensuales,
      if (otrosIngresos != null) 'otros_ingresos': otrosIngresos,
      if (documentoUrl != null) 'documento_url': documentoUrl,
      if (datosContextuales != null)
        'datos_contextuales':
            ApplicationContextDataModel.toJson(datosContextuales),
      if (nombreArrendatario != null) 'nombre_arrendatario': nombreArrendatario,
      if (telefonoArrendatario != null) 'telefono_arrendatario': telefonoArrendatario,
      if (nombreArrendador != null) 'nombre_arrendador': nombreArrendador,
      if (telefonoArrendador != null) 'telefono_arrendador': telefonoArrendador,
      if (tituloPropiedad != null) 'titulo_propiedad': tituloPropiedad,
      if (direccionPropiedad != null) 'direccion_propiedad': direccionPropiedad,
      if (precioRenta != null) 'precio_renta': precioRenta,
      if (refPersonales != null)
        'ref_personales': refPersonales!
            .map(
              (ref) => {
                'nombre': ref.nombre,
                'telefono': ref.telefono,
                'relacion': ref.relacion,
              },
            )
            .toList(),
    };
  }

  // Método específico para crear una nueva solicitud (sin id, created_at, updated_at)
  Map<String, dynamic> toJsonCreate() {
    return {
      'arrendatario_id': arrendatarioId,
      'arrendador_id': arrendadorId,
      'propiedad_id': propiedadId,
      'estado': estado,
      if (empresa != null) 'empresa': empresa,
      if (cargo != null) 'cargo': cargo,
      if (tiempoEmpleo != null) 'tiempo_empleo': tiempoEmpleo,
      if (ingresosMensuales != null) 'ingresos_mensuales': ingresosMensuales,
      if (otrosIngresos != null) 'otros_ingresos': otrosIngresos,
      if (documentoUrl != null) 'documento_url': documentoUrl,
      if (datosContextuales != null)
        'datos_contextuales':
            ApplicationContextDataModel.toJson(datosContextuales),
      if (refPersonales != null)
        'ref_personales': refPersonales!
            .map(
              (ref) => {
                'nombre': ref.nombre,
                'telefono': ref.telefono,
                'relacion': ref.relacion,
              },
            )
            .toList(),
    };
  }
}
