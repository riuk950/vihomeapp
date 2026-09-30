import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/data/models/user_reputation_model.dart';
import 'package:vihomeapp/domain/entities/user_reputation.dart';

void main() {
  group('UserReputationModel', () {
    test('is a subclass of UserReputation entity', () {
      final model = UserReputationModel.fromJson({
        'user_id': 'usr-1',
        'is_verified': true,
        'average_rating': 4.8,
        'total_reviews': 12,
      });

      expect(model, isA<UserReputation>());
    });

    test('deserializes complete JSON correctly with num to double conversion', () {
      final json = {
        'user_id': 'usr-landlord-01',
        'user_name': 'Beatriz Salazar',
        'is_verified': true,
        'average_rating': 5, // integer 5 from database
        'total_reviews': 8,
      };

      final model = UserReputationModel.fromJson(json);

      expect(model.userId, equals('usr-landlord-01'));
      expect(model.userName, equals('Beatriz Salazar'));
      expect(model.isVerified, isTrue);
      expect(model.averageRating, equals(5.0));
      expect(model.totalReviews, equals(8));
      expect(model.displayRating, equals(5.0));
    });

    test('serializes to JSON correctly', () {
      final model = UserReputationModel(
        userId: 'usr-landlord-01',
        userName: 'Beatriz Salazar',
        isVerified: true,
        averageRating: 4.8,
        totalReviews: 12,
      );

      final json = model.toJson();

      expect(json['user_id'], equals('usr-landlord-01'));
      expect(json['user_name'], equals('Beatriz Salazar'));
      expect(json['is_verified'], isTrue);
      expect(json['average_rating'], equals(4.8));
      expect(json['total_reviews'], equals(12));
    });
  });
}
