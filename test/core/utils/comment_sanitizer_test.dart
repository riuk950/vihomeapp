import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/core/utils/comment_sanitizer.dart';

void main() {
  group('CommentSanitizer', () {
    test('trims leading and trailing whitespace', () {
      final input = '   Excelente arrendador, muy amable.   ';
      expect(CommentSanitizer.sanitize(input), equals('Excelente arrendador, muy amable.'));
    });

    test('collapses excessive consecutive newlines to maximum of two', () {
      final input = 'Párrafo 1\n\n\n\n\nPárrafo 2\r\n\r\n\r\n\r\nPárrafo 3';
      final result = CommentSanitizer.sanitize(input);
      expect(result, equals('Párrafo 1\n\nPárrafo 2\n\nPárrafo 3'));
    });

    test('treats whitespace-only or newline-only string as null', () {
      expect(CommentSanitizer.sanitize('   \n\n\t  '), isNull);
      expect(CommentSanitizer.sanitize(''), isNull);
      expect(CommentSanitizer.sanitize(null), isNull);
    });

    test('truncates strings longer than 500 characters', () {
      final longText = 'a' * 550;
      final result = CommentSanitizer.sanitize(longText);
      expect(result, isNotNull);
      expect(result!.length, equals(500));
      expect(result, equals('a' * 500));
    });

    test('validates comment length within 500 chars limit', () {
      expect(CommentSanitizer.isValidLength('Texto corto'), isTrue);
      expect(CommentSanitizer.isValidLength('a' * 500), isTrue);
      expect(CommentSanitizer.isValidLength('a' * 501), isFalse);
      expect(CommentSanitizer.isValidLength(null), isTrue);
    });
  });
}
