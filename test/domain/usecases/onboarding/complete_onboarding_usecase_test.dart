import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/domain/entities/onboarding_state.dart';
import 'package:vihomeapp/domain/repositories/onboarding_repository.dart';
import 'package:vihomeapp/domain/usecases/onboarding/complete_onboarding_usecase.dart';

class MockOnboardingRepository implements OnboardingRepository {
  OnboardingCompletionReason? lastReason;
  int? lastStep;
  bool markResult = true;

  @override
  Future<OnboardingState> getOnboardingState() async => OnboardingState.notSeen();

  @override
  Future<bool> markOnboardingSeen({
    required OnboardingCompletionReason reason,
    required int lastStep,
  }) async {
    lastReason = reason;
    this.lastStep = lastStep;
    return markResult;
  }
}

void main() {
  late MockOnboardingRepository mockRepository;
  late CompleteOnboardingUseCase useCase;

  setUp(() {
    mockRepository = MockOnboardingRepository();
    useCase = CompleteOnboardingUseCase(mockRepository);
  });

  group('CompleteOnboardingUseCase', () {
    test('debe delegar en repository.markOnboardingSeen con los parámetros correspondientes', () async {
      final success = await useCase(
        reason: OnboardingCompletionReason.completed,
        step: 4,
      );

      expect(success, true);
      expect(mockRepository.lastReason, OnboardingCompletionReason.completed);
      expect(mockRepository.lastStep, 4);
    });

    test('debe retornar false si el repositorio falla al guardar', () async {
      mockRepository.markResult = false;

      final success = await useCase(
        reason: OnboardingCompletionReason.skipped,
        step: 2,
      );

      expect(success, false);
      expect(mockRepository.lastReason, OnboardingCompletionReason.skipped);
      expect(mockRepository.lastStep, 2);
    });
  });
}
