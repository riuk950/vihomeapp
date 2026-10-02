/// Categorías canónicas para la asignación de formularios contextuales de arrendamiento
enum PropertyCategory {
  residential,
  individual,
  commercial,
}

/// Clasificador canónico de tipos de inmuebles [RF-13.1, RF-13.2, CL-14]
class PropertyCategoryResolver {
  /// Clasifica una cadena arbitraria de tipo de inmueble en una categoría canónica.
  /// Aplica normalización de tildes, minúsculas y reglas de precedencia.
  /// En caso de tipo desconocido o nulo, aplica fallback a [PropertyCategory.residential].
  static PropertyCategory resolve(String? rawType) {
    if (rawType == null || rawType.trim().isEmpty) {
      return PropertyCategory.residential; // CL-14: Fallback
    }

    final normalized = _normalize(rawType);

    // 1. Precedencia Comercial
    if (normalized.contains('local') ||
        normalized.contains('oficina') ||
        normalized.contains('bodega') ||
        normalized.contains('comercial')) {
      return PropertyCategory.commercial;
    }

    // 2. Precedencia Individual / Estudiantil
    if (normalized.contains('habitacion') ||
        normalized.contains('cuarto') ||
        normalized.contains('apartaestudio') ||
        normalized.contains('aparta-estudio') ||
        normalized.contains('aparta estudio') ||
        normalized.contains('suite')) {
      return PropertyCategory.individual;
    }

    // 3. Precedencia Residencial Familiar
    if (normalized.contains('casa') ||
        normalized.contains('apartamento') ||
        normalized.contains('apto') ||
        normalized.contains('finca') ||
        normalized.contains('cabana') ||
        normalized.contains('lote') ||
        normalized.contains('vivienda')) {
      return PropertyCategory.residential;
    }

    // Fallback general
    return PropertyCategory.residential;
  }

  static String _normalize(String input) {
    return input
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u');
  }
}
