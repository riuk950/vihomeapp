import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vihomeapp/presentation/providers/subscription_provider.dart';
import '../../domain/services/fake_services_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SubscriptionProvider Flow Tests [RF-12.1, RF-12.2, RF-12.3, RF-12.4, RF-12.5, CL-09]', () {
    late FakeIapService fakeIap;
    late SubscriptionProvider provider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      fakeIap = FakeIapService();
      provider = SubscriptionProvider(iapService: fakeIap);
    });

    tearDown(() {
      provider.dispose();
      fakeIap.dispose();
    });

    test('should report error when store is not available [RF-12.2]', () async {
      fakeIap.available = false;

      await provider.initialize('usr_test_123');

      expect(provider.errorMessage, contains('tienda no está disponible'));
      expect(provider.isSubscribed, isFalse);
    });

    test('should activate subscription on successful purchase [RF-12.1]', () async {
      fakeIap.available = true;
      fakeIap.shouldSucceed = true;

      await provider.initialize('usr_test_123');
      final success = await provider.purchaseById('vihome_premium_monthly');

      expect(success, isTrue);
      expect(provider.isSubscribed, isTrue);
      expect(provider.errorMessage, isNull);
    });

    test('should handle user canceled purchase gracefully without error [RF-12.5]', () async {
      fakeIap.available = true;
      fakeIap.shouldSucceed = false;

      await provider.initialize('usr_test_123');
      final success = await provider.purchaseById('vihome_premium_monthly');

      expect(success, isFalse);
      expect(provider.isSubscribed, isFalse);
    });

    test('should restore purchases successfully [RF-12.3]', () async {
      fakeIap.available = true;

      await provider.initialize('usr_test_123');
      final success = await provider.restorePurchases();

      expect(success, isTrue);
      expect(provider.isSubscribed, isTrue);
    });
  });
}
