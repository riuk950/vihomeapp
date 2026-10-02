import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/domain/entities/user_reputation.dart';

void main() {
  group('UserReputation Entity', () {
    test('computes status and display rating correctly for verified user without reviews', () {
      final rep = UserReputation(
        userId: 'usr-ver-1',
        userName: 'Beatriz Salazar',
        isVerified: true,
        averageRating: null,
        totalReviews: 0,
      );

      expect(rep.displayRating, equals(3.0));
      expect(rep.isProvisional, isTrue);
      expect(rep.hasRealRatings, isFalse);
      expect(rep.statusLabel, equals('Puntaje inicial de confianza'));
      expect(rep.formattedRating, equals('3.0'));
    });

    test('computes neutral status for unverified user without reviews', () {
      final rep = UserReputation(
        userId: 'usr-anon-1',
        isVerified: false,
        averageRating: null,
        totalReviews: 0,
      );

      expect(rep.displayRating, isNull);
      expect(rep.isProvisional, isFalse);
      expect(rep.hasRealRatings, isFalse);
      expect(rep.statusLabel, equals('Sin calificaciones aún'));
      expect(rep.formattedRating, equals('—'));
    });

    test('computes real reputation for user with reviews', () {
      final rep = UserReputation(
        userId: 'usr-landlord-1',
        userName: 'Beatriz Salazar',
        isVerified: true,
        averageRating: 4.85, // round-half-up to 4.9
        totalReviews: 12,
      );

      expect(rep.displayRating, equals(4.9));
      expect(rep.isProvisional, isFalse);
      expect(rep.hasRealRatings, isTrue);
      expect(rep.statusLabel, equals('Basado en 12 reseñas'));
      expect(rep.formattedRating, equals('4.9'));
    });
  });
}
