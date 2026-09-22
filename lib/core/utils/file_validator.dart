/// Resultado de validación de archivo
class FileValidationResult {
  final bool isValid;
  final String? errorMessage;

  const FileValidationResult({
    required this.isValid,
    this.errorMessage,
  });

  factory FileValidationResult.success() => const FileValidationResult(isValid: true);
  factory FileValidationResult.error(String message) => FileValidationResult(
        isValid: false,
        errorMessage: message,
      );
}

/// Utilitario para validación de documentos y comprobantes [RF-10.2, RF-10.3, CL-08]
class FileValidator {
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10 MB
  static const Set<String> allowedExtensions = {'pdf', 'jpg', 'jpeg', 'png'};

  /// Valida el nombre y tamaño de un archivo
  static FileValidationResult validate({
    required String fileName,
    required int sizeInBytes,
  }) {
    if (sizeInBytes <= 0) {
      return FileValidationResult.error('El archivo está vacío o dañado.');
    }

    if (sizeInBytes > maxFileSizeBytes) {
      return FileValidationResult.error('El archivo excede el límite máximo de 10 MB.');
    }

    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return FileValidationResult.error('El archivo no tiene una extensión válida.');
    }

    final extension = fileName.substring(dotIndex + 1).toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return FileValidationResult.error(
        'Formato no permitido ($extension). Solo se admiten archivos PDF, JPG y PNG.',
      );
    }

    return FileValidationResult.success();
  }
}
