import '../entities/onboarding_state.dart';

/// Contrato para consultar y actualizar el estado de visualización del onboarding.
abstract class OnboardingRepository {
  /// Obtiene el estado actual persistido del onboarding de forma determinista y segura.
  Future<OnboardingState> getOnboardingState();

  /// Registra el onboarding como completado u omitido con su razón y paso.
  /// Retorna `true` si se guardó con éxito en el almacenamiento local, o `false` ante fallos internos.
  Future<bool> markOnboardingSeen({
    required OnboardingCompletionReason reason,
    required int lastStep,
  });
}
