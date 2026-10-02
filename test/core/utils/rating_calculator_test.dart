import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/core/utils/rating_calculator.dart';

void main() {
  group('RatingCalculator', () {
    test('calculates arithmetic average correctly with round-half-up', () {
      expect(RatingCalculator.calculateAverage([5, 5, 5]), equals(5.0));
      expect(RatingCalculator.calculateAverage([4, 5]), equals(4.5));
      // 4.85 -> 4.9 (round-half-up)
      // Note: [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4] -> sum 64 / 13 = 4.923
      expect(RatingCalculator.roundToOneDecimal(4.85), equals(4.9));
      expect(RatingCalculator.roundToOneDecimal(4.84), equals(4.8));
      expect(RatingCalculator.roundToOneDecimal(4.86), equals(4.9));
    });

    test('returns null when calculating average for empty ratings list', () {
      expect(RatingCalculator.calculateAverage([]), isNull);
    });

    test('returns neutral status for unverified user with zero reviews', () {
      final summary = RatingCalculator.getReputationSummary(
        totalReviews: 0,
        averageRating: null,
        isVerified: false,
      );

      expect(summary.displayRating, isNull);
      expect(summary.statusLabel, equals('Sin calificaciones aún'));
      expect(summary.isProvisional, isFalse);
      expect(summary.hasRealRatings, isFalse);
    });

    test('returns 3.0 provisional trust score for verified user with zero reviews', () {
      final summary = RatingCalculator.getReputationSummary(
        totalReviews: 0,
        averageRating: null,
        isVerified: true,
      );

      expect(summary.displayRating, equals(3.0));
      expect(summary.statusLabel, equals('Puntaje inicial de confianza'));
      expect(summary.isProvisional, isTrue);
      expect(summary.hasRealRatings, isFalse);
    });

    test('transitions to 100% real ratings when verified user receives first review', () {
      final summaryOneStar = RatingCalculator.getReputationSummary(
        totalReviews: 1,
        averageRating: 1.0,
        isVerified: true,
      );

      expect(summaryOneStar.displayRating, equals(1.0));
      expect(summaryOneStar.statusLabel, equals('Basado en 1 reseña'));
      expect(summaryOneStar.isProvisional, isFalse);
      expect(summaryOneStar.hasRealRatings, isTrue);

      final summaryFiveStars = RatingCalculator.getReputationSummary(
        totalReviews: 1,
        averageRating: 5.0,
        isVerified: true,
      );

      expect(summaryFiveStars.displayRating, equals(5.0));
      expect(summaryFiveStars.statusLabel, equals('Basado en 1 reseña'));
      expect(summaryFiveStars.isProvisional, isFalse);
      expect(summaryFiveStars.hasRealRatings, isTrue);
    });

    test('formats plural reviews correctly for multiple reviews', () {
      final summary = RatingCalculator.getReputationSummary(
        totalReviews: 12,
        averageRating: 4.8,
        isVerified: true,
      );

      expect(summary.displayRating, equals(4.8));
      expect(summary.statusLabel, equals('Basado en 12 reseñas'));
      expect(summary.isProvisional, isFalse);
      expect(summary.hasRealRatings, isTrue);
    });
  });
}
