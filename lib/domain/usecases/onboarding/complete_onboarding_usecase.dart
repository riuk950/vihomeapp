import '../../entities/onboarding_state.dart';
import '../../repositories/onboarding_repository.dart';

/// Caso de uso para registrar el onboarding como visto (completado u omitido).
class CompleteOnboardingUseCase {
  final OnboardingRepository repository;

  CompleteOnboardingUseCase(this.repository);

  Future<bool> call({
    required OnboardingCompletionReason reason,
    required int step,
  }) async {
    return await repository.markOnboardingSeen(
      reason: reason,
      lastStep: step,
    );
  }
}
