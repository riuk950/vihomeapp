import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/core/utils/file_validator.dart';

void main() {
  group('FileValidator [RF-10.2, RF-10.3, CL-08]', () {
    test('should validate valid PDF file within size limit', () {
      final result = FileValidator.validate(
        fileName: 'extracto_bancario.pdf',
        sizeInBytes: 2 * 1024 * 1024, // 2 MB
      );

      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('should validate valid JPG/PNG image files within size limit', () {
      final jpgResult = FileValidator.validate(
        fileName: 'cedula.jpg',
        sizeInBytes: 1 * 1024 * 1024,
      );
      expect(jpgResult.isValid, isTrue);

      final pngResult = FileValidator.validate(
        fileName: 'soporte.png',
        sizeInBytes: 500 * 1024,
      );
      expect(pngResult.isValid, isTrue);
    });

    test('should reject file with unsupported extension [RF-10.2]', () {
      final result = FileValidator.validate(
        fileName: 'documento.exe',
        sizeInBytes: 1024,
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Formato no permitido'));
    });

    test('should reject file exceeding 10 MB limit [RF-10.3]', () {
      final result = FileValidator.validate(
        fileName: 'archivo_pesado.pdf',
        sizeInBytes: 11 * 1024 * 1024, // 11 MB
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('10 MB'));
    });

    test('should reject empty file with 0 bytes [CL-08]', () {
      final result = FileValidator.validate(
        fileName: 'archivo_vacio.pdf',
        sizeInBytes: 0,
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('vacío'));
    });

    test('should reject file with no extension', () {
      final result = FileValidator.validate(
        fileName: 'archivo_sin_extension',
        sizeInBytes: 1024,
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, isNotNull);
    });
  });
}
