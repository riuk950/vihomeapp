import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/core/errors/review_exceptions.dart';

void main() {
  group('ReviewExceptions', () {
    test('SelfRatingNotAllowedException has default and custom messages', () {
      final defaultEx = SelfRatingNotAllowedException();
      expect(defaultEx.message, contains('No puedes calificarte a ti mismo'));
      expect(defaultEx.toString(), contains('SelfRatingNotAllowedException'));

      final customEx = SelfRatingNotAllowedException('Mensaje personalizado');
      expect(customEx.message, equals('Mensaje personalizado'));
    });

    test('AlreadyRatedException provides clear feedback', () {
      final ex = AlreadyRatedException();
      expect(ex.message, contains('Ya has emitido una calificación'));
    });

    test('RatingWindowExpiredException provides clear feedback', () {
      final ex = RatingWindowExpiredException();
      expect(ex.message, contains('plazo para calificar'));
    });

    test('UnauthorizedRatingException provides clear feedback', () {
      final ex = UnauthorizedRatingException();
      expect(ex.message, contains('No tienes autorización para calificar'));
    });

    test('TargetUserUnavailableException provides clear feedback', () {
      final ex = TargetUserUnavailableException();
      expect(ex.message, contains('usuario a evaluar ya no se encuentra disponible'));
    });

    test('SessionExpiredRatingException provides clear feedback', () {
      final ex = SessionExpiredRatingException();
      expect(ex.message, contains('sesión ha expirado'));
    });
  });
}
