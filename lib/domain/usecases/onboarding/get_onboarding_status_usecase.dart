import '../../entities/onboarding_state.dart';
import '../../repositories/onboarding_repository.dart';

/// Caso de uso para obtener el estado persistido del onboarding inicial.
class GetOnboardingStatusUseCase {
  final OnboardingRepository repository;

  GetOnboardingStatusUseCase(this.repository);

  Future<OnboardingState> call() async {
    return await repository.getOnboardingState();
  }
}
