class SubscriptionIds {
  // --- IDs REALES de Google Play Console ---
  // Estos IDs deben coincidir EXACTAMENTE con los de Google Play Console.
  // El sandbox de Google Play funciona con los mismos IDs que producción.
  static const String mensual = 'suscripcion.mensual.premium';
  static const String semestral = 'suscripcion.semestral.premium';
  static const String anual = 'suscripcion.anual.premium';

  // Lista completa de IDs
  static const Set<String> all = {mensual, semestral, anual};

  // ID base usado en configuraciones (ej. FlutterSecureStorage)
  static const String productIdBase = 'suscripcion.premium';
}
