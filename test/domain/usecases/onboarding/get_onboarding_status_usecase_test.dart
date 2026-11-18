import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/domain/entities/onboarding_state.dart';
import 'package:vihomeapp/domain/repositories/onboarding_repository.dart';
import 'package:vihomeapp/domain/usecases/onboarding/get_onboarding_status_usecase.dart';

class MockOnboardingRepository implements OnboardingRepository {
  OnboardingState stateToReturn = OnboardingState.notSeen();
  bool markResult = true;

  @override
  Future<OnboardingState> getOnboardingState() async => stateToReturn;

  @override
  Future<bool> markOnboardingSeen({
    required OnboardingCompletionReason reason,
    required int lastStep,
  }) async => markResult;
}

void main() {
  late MockOnboardingRepository mockRepository;
  late GetOnboardingStatusUseCase useCase;

  setUp(() {
    mockRepository = MockOnboardingRepository();
    useCase = GetOnboardingStatusUseCase(mockRepository);
  });

  group('GetOnboardingStatusUseCase', () {
    test('debe delegar en repository.getOnboardingState()', () async {
      const expected = OnboardingState(
        hasSeenOnboarding: true,
        completionReason: OnboardingCompletionReason.completed,
        lastCompletedStep: 4,
      );
      mockRepository.stateToReturn = expected;

      final result = await useCase();
      expect(result, equals(expected));
    });
  });
}
