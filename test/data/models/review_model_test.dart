import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/data/models/review_model.dart';
import 'package:vihomeapp/domain/entities/review.dart';

void main() {
  group('ReviewModel', () {
    final now = DateTime.parse('2026-09-30T14:35:00.000Z');

    final jsonMap = {
      'id': 'rev-5001-aaaa-bbbb',
      'solicitud_id': 'sol-1002-cccc-dddd',
      'reviewer_id': 'usr-tenant-01',
      'reviewer_name': 'Carlos Alberto Restrepo',
      'target_user_id': 'usr-landlord-01',
      'rating': 5,
      'comment': 'Excelente atención durante todo el proceso.',
      'created_at': '2026-09-30T14:35:00.000Z',
    };

    test('is a subclass of Review entity', () {
      final model = ReviewModel.fromJson(jsonMap);
      expect(model, isA<Review>());
    });

    test('deserializes complete JSON correctly', () {
      final model = ReviewModel.fromJson(jsonMap);

      expect(model.id, equals('rev-5001-aaaa-bbbb'));
      expect(model.solicitudId, equals('sol-1002-cccc-dddd'));
      expect(model.reviewerId, equals('usr-tenant-01'));
      expect(model.reviewerName, equals('Carlos Alberto Restrepo'));
      expect(model.targetUserId, equals('usr-landlord-01'));
      expect(model.rating, equals(5));
      expect(model.comment, equals('Excelente atención durante todo el proceso.'));
      expect(model.createdAt, equals(now));
    });

    test('deserializes JSON with null comment and missing reviewer name safely', () {
      final minimalJson = {
        'id': 'rev-5002',
        'solicitud_id': 'sol-1002',
        'reviewer_id': 'usr-1',
        'target_user_id': 'usr-2',
        'rating': 4,
        'comment': null,
        'created_at': '2026-09-30T14:35:00.000Z',
      };

      final model = ReviewModel.fromJson(minimalJson);
      expect(model.comment, isNull);
      expect(model.reviewerName, isNull);
    });

    test('serializes to JSON correctly', () {
      final model = ReviewModel.fromJson(jsonMap);
      final serialized = model.toJson();

      expect(serialized['id'], equals('rev-5001-aaaa-bbbb'));
      expect(serialized['solicitud_id'], equals('sol-1002-cccc-dddd'));
      expect(serialized['reviewer_id'], equals('usr-tenant-01'));
      expect(serialized['reviewer_name'], equals('Carlos Alberto Restrepo'));
      expect(serialized['target_user_id'], equals('usr-landlord-01'));
      expect(serialized['rating'], equals(5));
      expect(serialized['comment'], equals('Excelente atención durante todo el proceso.'));
      expect(serialized['created_at'], equals('2026-09-30T14:35:00.000Z'));
    });
  });
}
