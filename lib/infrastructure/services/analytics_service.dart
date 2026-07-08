import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver getObserver() =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Registra el inicio de sesión del usuario
  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  /// Registra cuando un usuario ve una propiedad
  Future<void> logViewProperty(String propertyId, String propertyName) async {
    await _analytics.logEvent(
      name: 'view_property',
      parameters: {
        'property_id': propertyId,
        'property_name': propertyName,
      },
    );
  }

  /// Registra el inicio del proceso de suscripción
  Future<void> logSubscriptionStarted(String planId) async {
    await _analytics.logEvent(
      name: 'subscription_started',
      parameters: {
        'plan_id': planId,
      },
    );
  }

  /// Registra una suscripción exitosa
  Future<void> logSubscriptionSuccess(String planId) async {
    await _analytics.logPurchase(
      currency: 'USD',
      value: planId.contains('monthly') ? 9.99 : 99.99, // Ajustar según precios reales
      items: [
        AnalyticsEventItem(
          itemId: planId,
          itemName: 'Premium Plan',
          itemCategory: 'Subscription',
        ),
      ],
    );
  }

  /// Registra cuando se publica una propiedad
  Future<void> logPropertyPublished(String propertyType) async {
    await _analytics.logEvent(
      name: 'property_published',
      parameters: {
        'property_type': propertyType,
      },
    );
  }
  
  /// Registra la navegación entre pantallas
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }
}
