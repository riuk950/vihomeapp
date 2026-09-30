import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/core/errors/review_exceptions.dart';
import 'package:vihomeapp/domain/entities/review.dart';

void main() {
  group('Review Entity', () {
    final now = DateTime(2026, 9, 30, 14, 0, 0);

    test('creates valid review successfully', () {
      final review = Review(
        id: 'rev-1',
        solicitudId: 'sol-1',
        reviewerId: 'usr-1',
        reviewerName: 'Carlos',
        targetUserId: 'usr-2',
        rating: 5,
        comment: 'Excelente experiencia.',
        createdAt: now,
      );

      expect(review.id, equals('rev-1'));
      expect(review.rating, equals(5));
      expect(review.comment, equals('Excelente experiencia.'));
    });

    test('throws SelfRatingNotAllowedException when reviewerId equals targetUserId', () {
      expect(
        () => Review(
          id: 'rev-2',
          solicitudId: 'sol-1',
          reviewerId: 'usr-same',
          targetUserId: 'usr-same',
          rating: 5,
          createdAt: now,
        ),
        throwsA(isA<SelfRatingNotAllowedException>()),
      );
    });

    test('throws ReviewValidationException when rating is less than 1 or greater than 5', () {
      expect(
        () => Review(
          id: 'rev-3',
          solicitudId: 'sol-1',
          reviewerId: 'usr-1',
          targetUserId: 'usr-2',
          rating: 0,
          createdAt: now,
        ),
        throwsA(isA<ReviewValidationException>()),
      );

      expect(
        () => Review(
          id: 'rev-4',
          solicitudId: 'sol-1',
          reviewerId: 'usr-1',
          targetUserId: 'usr-2',
          rating: 6,
          createdAt: now,
        ),
        throwsA(isA<ReviewValidationException>()),
      );
    });

    test('supports value equality', () {
      final review1 = Review(
        id: 'rev-1',
        solicitudId: 'sol-1',
        reviewerId: 'usr-1',
        targetUserId: 'usr-2',
        rating: 4,
        createdAt: now,
      );

      final review2 = Review(
        id: 'rev-1',
        solicitudId: 'sol-1',
        reviewerId: 'usr-1',
        targetUserId: 'usr-2',
        rating: 4,
        createdAt: now,
      );

      expect(review1, equals(review2));
      expect(review1.hashCode, equals(review2.hashCode));
    });
  });
}
