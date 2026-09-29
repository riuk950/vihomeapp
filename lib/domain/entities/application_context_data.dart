import 'package:flutter/foundation.dart';

/// Información del acudiente o tutor legal para solicitantes menores de edad [RF-15.3]
@immutable
class GuardianInfo {
  final String nombreCompleto;
  final String telefono;
  final String parentesco;

  const GuardianInfo({
    required this.nombreCompleto,
    required this.telefono,
    required this.parentesco,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuardianInfo &&
          runtimeType == other.runtimeType &&
          nombreCompleto == other.nombreCompleto &&
          telefono == other.telefono &&
          parentesco == other.parentesco;

  @override
  int get hashCode =>
      nombreCompleto.hashCode ^ telefono.hashCode ^ parentesco.hashCode;
}

/// Jerarquía sellada para representar los datos contextuales según la tipología del inmueble [RF-13.2]
sealed class ApplicationContextData {
  const ApplicationContextData();
}

/// Datos contextuales para inmuebles residenciales familiares (Casas, Apartamentos, Fincas) [RF-14]
class ResidentialContextData extends ApplicationContextData {
  final int numeroOcupantes;
  final String descripcionFamiliar;
  final bool tieneMascotas;
  final String? detalleMascotas;

  const ResidentialContextData({
    required this.numeroOcupantes,
    required this.descripcionFamiliar,
    required this.tieneMascotas,
    this.detalleMascotas,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResidentialContextData &&
          runtimeType == other.runtimeType &&
          numeroOcupantes == other.numeroOcupantes &&
          descripcionFamiliar == other.descripcionFamiliar &&
          tieneMascotas == other.tieneMascotas &&
          detalleMascotas == other.detalleMascotas;

  @override
  int get hashCode =>
      numeroOcupantes.hashCode ^
      descripcionFamiliar.hashCode ^
      tieneMascotas.hashCode ^
      (detalleMascotas?.hashCode ?? 0);
}

/// Datos contextuales para habitaciones o apartaestudios individuales [RF-15]
class IndividualContextData extends ApplicationContextData {
  final String ocupacion;
  final String entidadLaboralEducativa;
  final bool esMenorDeEdad;
  final GuardianInfo? acudiente;

  const IndividualContextData({
    required this.ocupacion,
    required this.entidadLaboralEducativa,
    required this.esMenorDeEdad,
    this.acudiente,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IndividualContextData &&
          runtimeType == other.runtimeType &&
          ocupacion == other.ocupacion &&
          entidadLaboralEducativa == other.entidadLaboralEducativa &&
          esMenorDeEdad == other.esMenorDeEdad &&
          acudiente == other.acudiente;

  @override
  int get hashCode =>
      ocupacion.hashCode ^
      entidadLaboralEducativa.hashCode ^
      esMenorDeEdad.hashCode ^
      (acudiente?.hashCode ?? 0);
}

/// Datos contextuales para inmuebles comerciales (Locales, Oficinas, Bodegas) [RF-16]
class CommercialContextData extends ApplicationContextData {
  final String razonSocial;
  final String nit;
  final String actividadEconomica;

  const CommercialContextData({
    required this.razonSocial,
    required this.nit,
    required this.actividadEconomica,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommercialContextData &&
          runtimeType == other.runtimeType &&
          razonSocial == other.razonSocial &&
          nit == other.nit &&
          actividadEconomica == other.actividadEconomica;

  @override
  int get hashCode =>
      razonSocial.hashCode ^ nit.hashCode ^ actividadEconomica.hashCode;
}
