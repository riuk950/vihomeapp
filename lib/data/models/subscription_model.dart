import '../../domain/entities/subscription.dart';

/// Modelo de datos para suscripciones que extiende Subscription
class SubscriptionModel extends Subscription {
  const SubscriptionModel({
    required super.id,
    required super.userId,
    required super.planType,
    required super.status,
    required super.maxProperties,
    required super.adsEnabled,
    super.currentPeriodStart,
    super.currentPeriodEnd,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      planType: json['plan_type'] as String? ?? 'free',
      status: json['status'] as String? ?? 'active',
      maxProperties: json['max_properties'] as int? ?? 1,
      adsEnabled: json['ads_enabled'] as bool? ?? true,
      currentPeriodStart: json['current_period_start'] != null
          ? DateTime.parse(json['current_period_start'] as String)
          : null,
      currentPeriodEnd: json['current_period_end'] != null
          ? DateTime.parse(json['current_period_end'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan_type': planType,
      'status': status,
      'max_properties': maxProperties,
      'ads_enabled': adsEnabled,
      'current_period_start': currentPeriodStart?.toIso8601String(),
      'current_period_end': currentPeriodEnd?.toIso8601String(),
    };
  }
}
