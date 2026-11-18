/// Claves persistentes para almacenamiento local en SharedPreferences.
class StorageKeys {
  StorageKeys._();

  /// Clave para persistir el estado y metadatos del onboarding inicial en JSON.
  static const String onboardingState = 'vihome_onboarding_state_v1';
}

/// Constante de compatibilidad directa.
const String kOnboardingStateKey = StorageKeys.onboardingState;
