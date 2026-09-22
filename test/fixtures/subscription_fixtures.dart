/// Fixtures de prueba para Suscripciones y Límites [RF-05.2, RF-07]
class SubscriptionFixtures {
  static const Map<String, dynamic> validPremiumSubscriptionJson = {
    'id': 'sub_7c8d9e0f-1a2b-3c4d-5e6f-7a8b9c0d1e2f',
    'user_id': 'usr_9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d',
    'plan_type': 'premium',
    'status': 'active',
    'max_properties': -1,
    'ads_enabled': false,
    'current_period_start': '2026-03-01T00:00:00.000Z',
    'current_period_end': '2026-04-01T00:00:00.000Z',
  };

  static const Map<String, dynamic> validFreePlanSubscriptionJson = {
    'id': 'sub_free_default',
    'user_id': 'usr_9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d',
    'plan_type': 'free',
    'status': 'active',
    'max_properties': 1,
    'ads_enabled': true,
    'current_period_start': '2026-03-01T00:00:00.000Z',
    'current_period_end': null,
  };

  static const Map<String, dynamic> expiredSubscriptionJson = {
    'id': 'sub_expired',
    'user_id': 'usr_9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d',
    'plan_type': 'premium',
    'status': 'expired',
    'max_properties': 1,
    'ads_enabled': true,
    'current_period_start': '2026-02-01T00:00:00.000Z',
    'current_period_end': '2026-03-01T00:00:00.000Z',
  };
}
