/// Validador de reglas de negocio para formularios contextuales [RF-14, RF-15, RF-16, CL-10, CL-11, CL-12]
class ContextualFormValidator {
  // Regex para nombres en español con acentos, diéresis, espacios y apóstrofes
  static final RegExp _nameRegex = RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s'-]{5,80}$");

  // Regex para NIT: alfanumérico, puntos y guiones (6 a 20 caracteres)
  static final RegExp _nitRegex = RegExp(r'^[a-zA-Z0-9.\-]{6,20}$');

  // Regex para teléfono: 10 dígitos nacionales o 7-15 con prefijo internacional '+'
  static final RegExp _phoneRegex = RegExp(r'^(\+?[0-9]{7,15}|[0-9]{10})$');

  // ==========================================
  // Residencial Familiar [RF-14, CL-10, CL-12]
  // ==========================================

  /// Valida número de ocupantes (entero entre 1 y 20)
  static String? validateOccupants(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa el número de personas.';
    }
    final intValue = int.tryParse(value.trim());
    if (intValue == null) {
      return 'Ingresa un número válido de ocupantes.';
    }
    if (intValue <= 0) {
      return 'El número de personas debe ser mínimo 1.';
    }
    if (intValue > 20) {
      return 'El número máximo de personas permitido es 20.';
    }
    return null;
  }

  /// Valida descripción del núcleo familiar (10 a 500 caracteres)
  static String? validateFamilyDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor describe cómo está compuesto el núcleo familiar.';
    }
    final length = value.trim().length;
    if (length < 10) {
      return 'La descripción debe tener al menos 10 caracteres.';
    }
    if (length > 500) {
      return 'La descripción no puede superar los 500 caracteres.';
    }
    return null;
  }

  /// Valida detalle de mascotas de manera condicional (3 a 150 caracteres)
  static String? validatePetDetails({
    required bool hasPets,
    required String? details,
  }) {
    if (!hasPets) return null;
    if (details == null || details.trim().isEmpty) {
      return 'Por favor especifica el tipo y cantidad de mascotas.';
    }
    final length = details.trim().length;
    if (length < 3) {
      return 'El detalle de mascotas debe tener al menos 3 caracteres.';
    }
    if (length > 150) {
      return 'El detalle de mascotas no puede exceder 150 caracteres.';
    }
    return null;
  }

  // ==========================================
  // Habitación / Individual [RF-15, CL-11]
  // ==========================================

  /// Valida ocupación principal
  static String? validateOccupation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Selecciona tu ocupación principal.';
    }
    return null;
  }

  /// Valida lugar de estudio o trabajo (3 a 100 caracteres)
  static String? validateWorkplaceOrSchool(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa el nombre de la institución educativa o empresa.';
    }
    final length = value.trim().length;
    if (length < 3) {
      return 'El nombre debe tener al menos 3 caracteres.';
    }
    if (length > 100) {
      return 'El nombre no puede superar los 100 caracteres.';
    }
    return null;
  }

  /// Valida nombre del acudiente si el solicitante es menor de edad
  static String? validateGuardianName({
    required bool isMinor,
    required String? name,
  }) {
    if (!isMinor) return null;
    if (name == null || name.trim().isEmpty) {
      return 'Ingresa el nombre completo del acudiente o responsable.';
    }
    final trimmed = name.trim();
    if (trimmed.length < 5) {
      return 'El nombre del acudiente debe tener al menos 5 caracteres.';
    }
    if (trimmed.length > 80) {
      return 'El nombre del acudiente no puede exceder 80 caracteres.';
    }
    if (!_nameRegex.hasMatch(trimmed)) {
      return 'El nombre del acudiente solo debe contener letras.';
    }
    return null;
  }

  /// Valida teléfono del acudiente si el solicitante es menor de edad
  static String? validateGuardianPhone({
    required bool isMinor,
    required String? phone,
  }) {
    if (!isMinor) return null;
    if (phone == null || phone.trim().isEmpty) {
      return 'Ingresa el número telefónico del acudiente.';
    }
    final clean = phone.trim().replaceAll(' ', '');
    if (!_phoneRegex.hasMatch(clean)) {
      return 'Ingresa un número telefónico válido (10 dígitos).';
    }
    return null;
  }

  /// Valida parentesco con el acudiente si el solicitante es menor de edad
  static String? validateGuardianRelationship({
    required bool isMinor,
    required String? relationship,
  }) {
    if (!isMinor) return null;
    if (relationship == null || relationship.trim().isEmpty) {
      return 'Selecciona o indica el parentesco con el acudiente.';
    }
    return null;
  }

  // ==========================================
  // Comercial [RF-16]
  // ==========================================

  /// Valida nombre comercial o razón social (3 a 100 caracteres)
  static String? validateBusinessName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa el nombre comercial o razón social.';
    }
    final length = value.trim().length;
    if (length < 3) {
      return 'La razón social debe tener al menos 3 caracteres.';
    }
    if (length > 100) {
      return 'La razón social no puede exceder 100 caracteres.';
    }
    return null;
  }

  /// Valida NIT o documento tributario (6 a 20 caracteres alfanuméricos con puntos o guión)
  static String? validateNit(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa el NIT o documento tributario.';
    }
    final trimmed = value.trim();
    if (!_nitRegex.hasMatch(trimmed)) {
      return 'Ingresa un NIT válido (entre 6 y 20 caracteres).';
    }
    return null;
  }

  /// Valida descripción de actividad económica (10 a 500 caracteres)
  static String? validateEconomicActivity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Describe la actividad económica y uso previsto del inmueble.';
    }
    final length = value.trim().length;
    if (length < 10) {
      return 'La descripción de la actividad debe tener al menos 10 caracteres.';
    }
    if (length > 500) {
      return 'La descripción no puede superar los 500 caracteres.';
    }
    return null;
  }
}
