/// Entidad de dominio para suscripciones [RF-05.2, RF-07]
class Subscription {
  final String id;
  final String userId;
  final String planType; // 'free' o 'premium'
  final String status;   // 'active', 'expired', 'canceled'
  final int maxProperties; // 1 para free, -1 para ilimitadas
  final bool adsEnabled;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;

  const Subscription({
    required this.id,
    required this.userId,
    required this.planType,
    required this.status,
    required this.maxProperties,
    required this.adsEnabled,
    this.currentPeriodStart,
    this.currentPeriodEnd,
  });

  bool get isPremiumActive => planType == 'premium' && status == 'active';
}
