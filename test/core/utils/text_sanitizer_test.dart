import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/core/utils/text_sanitizer.dart';

void main() {
  group('TextSanitizer', () {
    test('RF-18.4, QA 1.15: cleanSingleLine removes explicit newlines and trims extra spaces', () {
      const input = 'Apartamento 402\nEdificio\r\nLos   Sauces\t ';
      final result = TextSanitizer.cleanSingleLine(input);
      expect(result, 'Apartamento 402 Edificio Los Sauces');
    });

    test('cleanSingleLine handles null and empty strings gracefully', () {
      expect(TextSanitizer.cleanSingleLine(null), '');
      expect(TextSanitizer.cleanSingleLine(''), '');
      expect(TextSanitizer.cleanSingleLine('   \n  \t '), '');
    });

    test('CL-15, RF-18.4: truncate truncates text exceeding maxLength and appends suffix', () {
      const longTitle = 'Casa Campestre Muy Grande Con Piscina Climatizada y Jardines Gigantes';
      final truncated = TextSanitizer.truncate(longTitle, maxLength: 30);
      expect(truncated, 'Casa Campestre Muy Grande Con ...');
      expect(truncated.length, 33);
    });

    test('truncate leaves strings shorter than or equal to maxLength untouched', () {
      const shortTitle = 'Apartamento Centro';
      final result = TextSanitizer.truncate(shortTitle, maxLength: 30);
      expect(result, 'Apartamento Centro');
    });

    test('sanitizePhone cleans non-digit characters keeping optional leading plus', () {
      expect(TextSanitizer.sanitizePhone('+57 (312) 456-7890'), '+573124567890');
      expect(TextSanitizer.sanitizePhone('300.987.6543'), '3009876543');
      expect(TextSanitizer.sanitizePhone(null), '');
      expect(TextSanitizer.sanitizePhone(''), '');
    });
  });
}
