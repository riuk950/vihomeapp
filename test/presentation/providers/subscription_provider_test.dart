import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/data/models/subscription_model.dart';
import 'package:vihomeapp/presentation/pages/suscripciones/subscription_ids.dart';
import '../../fixtures/fixtures.dart';

void main() {
  group('Subscription Logic & Product Identifiers Tests [RF-05.2, RF-07]', () {
    test('SubscriptionIds should contain expected Google Play product IDs [RF-07.2]', () {
      expect(SubscriptionIds.mensual, 'suscripcion.mensual.premium');
      expect(SubscriptionIds.semestral, 'suscripcion.semestral.premium');
      expect(SubscriptionIds.anual, 'suscripcion.anual.premium');
      expect(SubscriptionIds.all, containsAll([
        SubscriptionIds.mensual,
        SubscriptionIds.semestral,
        SubscriptionIds.anual,
      ]));
    });

    test('Active premium subscription should suppress ads and allow unlimited properties [RF-05.3, RF-07.2]', () {
      final sub = SubscriptionModel.fromJson(SubscriptionFixtures.validPremiumSubscriptionJson);

      expect(sub.isPremiumActive, isTrue);
      expect(sub.adsEnabled, isFalse);
      expect(sub.maxProperties, -1);
    });

    test('Free plan subscription should enable ads and enforce 1 property limit [RF-05.2, RF-07.1]', () {
      final sub = SubscriptionModel.fromJson(SubscriptionFixtures.validFreePlanSubscriptionJson);

      expect(sub.isPremiumActive, isFalse);
      expect(sub.adsEnabled, isTrue);
      expect(sub.maxProperties, 1);
    });

    test('Expired subscription should revert to free plan limits and show ads [RF-07.3]', () {
      final sub = SubscriptionModel.fromJson(SubscriptionFixtures.expiredSubscriptionJson);

      expect(sub.isPremiumActive, isFalse);
      expect(sub.adsEnabled, isTrue);
      expect(sub.maxProperties, 1);
    });
  });
}
