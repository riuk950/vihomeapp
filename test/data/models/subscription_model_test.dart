import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/data/models/subscription_model.dart';
import 'package:vihomeapp/domain/entities/subscription.dart';
import '../../fixtures/fixtures.dart';

void main() {
  group('SubscriptionModel Serialization & Domain Entity Tests [RF-05.2, RF-07]', () {
    test('should correctly deserialize valid premium subscription JSON into SubscriptionModel', () {
      final json = SubscriptionFixtures.validPremiumSubscriptionJson;
      final model = SubscriptionModel.fromJson(json);

      expect(model.id, json['id']);
      expect(model.userId, json['user_id']);
      expect(model.planType, 'premium');
      expect(model.status, 'active');
      expect(model.maxProperties, -1);
      expect(model.adsEnabled, isFalse);
      expect(model.isPremiumActive, isTrue);
      expect(model, isA<Subscription>());
    });

    test('should correctly deserialize valid free plan subscription JSON into SubscriptionModel', () {
      final json = SubscriptionFixtures.validFreePlanSubscriptionJson;
      final model = SubscriptionModel.fromJson(json);

      expect(model.planType, 'free');
      expect(model.maxProperties, 1);
      expect(model.adsEnabled, isTrue);
      expect(model.isPremiumActive, isFalse);
    });

    test('should identify expired premium subscription as inactive premium', () {
      final json = SubscriptionFixtures.expiredSubscriptionJson;
      final model = SubscriptionModel.fromJson(json);

      expect(model.status, 'expired');
      expect(model.isPremiumActive, isFalse);
      expect(model.adsEnabled, isTrue);
    });

    test('should serialize SubscriptionModel back to JSON matching expected structure', () {
      final model = SubscriptionModel.fromJson(SubscriptionFixtures.validPremiumSubscriptionJson);
      final json = model.toJson();

      expect(json['id'], model.id);
      expect(json['plan_type'], 'premium');
      expect(json['ads_enabled'], isFalse);
      expect(json['max_properties'], -1);
    });
  });
}
