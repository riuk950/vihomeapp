import 'package:flutter_test/flutter_test.dart';
import 'fixtures.dart';

void main() {
  group('Fixtures Integrity Tests', () {
    test('User fixtures should have expected keys and non-empty values', () {
      expect(UserFixtures.validLandlordJson['id'], isNotEmpty);
      expect(UserFixtures.validLandlordJson['role'], 'landlord');
      expect(UserFixtures.validTenantJson['role'], 'tenant');
    });

    test('Property fixtures should contain required properties', () {
      expect(PropertyFixtures.validApartmentBogotaJson['ciudad'], 'Bogotá');
      expect(PropertyFixtures.validApartmentBogotaJson['precio'], isPositive);
      expect(PropertyFixtures.validApartmentBogotaJson['fotos'], isNotEmpty);
    });

    test('Application fixtures should contain financial proof documents', () {
      expect(ApplicationFixtures.validPendingApplicationJson['ingresos_mensuales'], isNotEmpty);
      expect(ApplicationFixtures.validPendingApplicationJson['documento_url'], isNotEmpty);
      expect(ApplicationFixtures.validPendingApplicationJson['estado'], 'Pendiente');
    });

    test('Subscription fixtures should correctly differentiate free and premium plans', () {
      expect(SubscriptionFixtures.validFreePlanSubscriptionJson['ads_enabled'], isTrue);
      expect(SubscriptionFixtures.validFreePlanSubscriptionJson['max_properties'], 1);
      expect(SubscriptionFixtures.validPremiumSubscriptionJson['ads_enabled'], isFalse);
      expect(SubscriptionFixtures.validPremiumSubscriptionJson['max_properties'], -1);
    });
  });
}
