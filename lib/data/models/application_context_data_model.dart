import 'package:vihomeapp/domain/entities/application_context_data.dart';

/// Modelo de serialización para los datos contextuales de una solicitud [RF-14, RF-15, RF-16, RF-17]
class ApplicationContextDataModel {
  /// Deserializa un Map JSON en la entidad de datos contextuales correspondiente.
  /// Retorna `null` si el JSON es nulo, vacío o no corresponde a una categoría válida (compatibilidad legacy).
  static ApplicationContextData? fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return null;

    final category = json['tipo_categoria']?.toString().toLowerCase();

    switch (category) {
      case 'residencial':
        return ResidentialContextData(
          numeroOcupantes: (json['numero_ocupantes'] as num?)?.toInt() ?? 1,
          descripcionFamiliar: json['descripcion_familiar']?.toString() ?? '',
          tieneMascotas: json['tiene_mascotas'] as bool? ?? false,
          detalleMascotas: json['detalle_mascotas']?.toString(),
        );

      case 'individual':
        GuardianInfo? guardian;
        if (json['acudiente'] != null && json['acudiente'] is Map) {
          final guardianJson = json['acudiente'] as Map<String, dynamic>;
          guardian = GuardianInfo(
            nombreCompleto: guardianJson['nombre_completo']?.toString() ?? '',
            telefono: guardianJson['telefono']?.toString() ?? '',
            parentesco: guardianJson['parentesco']?.toString() ?? '',
          );
        }
        return IndividualContextData(
          ocupacion: json['ocupacion']?.toString() ?? '',
          entidadLaboralEducativa:
              json['entidad_laboral_educativa']?.toString() ?? '',
          esMenorDeEdad: json['es_menor_de_edad'] as bool? ?? false,
          acudiente: guardian,
        );

      case 'comercial':
        return CommercialContextData(
          razonSocial: json['razon_social']?.toString() ?? '',
          nit: json['nit']?.toString() ?? '',
          actividadEconomica: json['actividad_economica']?.toString() ?? '',
        );

      default:
        return null;
    }
  }

  /// Serializa la entidad de datos contextuales a un Map JSON.
  /// Retorna `null` si la entidad es nula.
  static Map<String, dynamic>? toJson(ApplicationContextData? data) {
    if (data == null) return null;

    return switch (data) {
      ResidentialContextData res => {
          'tipo_categoria': 'residencial',
          'numero_ocupantes': res.numeroOcupantes,
          'descripcion_familiar': res.descripcionFamiliar,
          'tiene_mascotas': res.tieneMascotas,
          if (res.detalleMascotas != null) 'detalle_mascotas': res.detalleMascotas,
        },
      IndividualContextData ind => {
          'tipo_categoria': 'individual',
          'ocupacion': ind.ocupacion,
          'entidad_laboral_educativa': ind.entidadLaboralEducativa,
          'es_menor_de_edad': ind.esMenorDeEdad,
          if (ind.acudiente != null)
            'acudiente': {
              'nombre_completo': ind.acudiente!.nombreCompleto,
              'telefono': ind.acudiente!.telefono,
              'parentesco': ind.acudiente!.parentesco,
            },
        },
      CommercialContextData com => {
          'tipo_categoria': 'comercial',
          'razon_social': com.razonSocial,
          'nit': com.nit,
          'actividad_economica': com.actividadEconomica,
        },
    };
  }
}
