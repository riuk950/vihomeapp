import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/data/datasources/onboarding_local_datasource.dart';
import 'package:vihomeapp/data/models/onboarding_state_model.dart';
import 'package:vihomeapp/data/repositories/onboarding_repository_impl.dart';
import 'package:vihomeapp/domain/entities/onboarding_state.dart';

class MockOnboardingLocalDataSource implements OnboardingLocalDataSource {
  OnboardingStateModel stateToReturn = OnboardingStateModel.notSeen();
  bool shouldThrow = false;
  bool saveResult = true;
  OnboardingStateModel? lastSavedState;

  @override
  Future<OnboardingStateModel> getOnboardingState() async {
    if (shouldThrow) throw Exception('Disk read error');
    return stateToReturn;
  }

  @override
  Future<bool> saveOnboardingState(OnboardingStateModel state) async {
    if (shouldThrow) throw Exception('Disk write error');
    lastSavedState = state;
    return saveResult;
  }
}

void main() {
  late MockOnboardingLocalDataSource mockDataSource;
  late OnboardingRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockOnboardingLocalDataSource();
    repository = OnboardingRepositoryImpl(localDataSource: mockDataSource);
  });

  group('OnboardingRepositoryImpl', () {
    test('getOnboardingState retorna el estado desde el datasource', () async {
      mockDataSource.stateToReturn = const OnboardingStateModel(
        hasSeenOnboarding: true,
        completionReason: OnboardingCompletionReason.completed,
        lastCompletedStep: 4,
      );

      final state = await repository.getOnboardingState();
      expect(state.hasSeenOnboarding, true);
      expect(state.completionReason, OnboardingCompletionReason.completed);
    });

    test('getOnboardingState retorna notSeen de respaldo determinista ante excepción (RF-8.3)', () async {
      mockDataSource.shouldThrow = true;

      final state = await repository.getOnboardingState();
      expect(state.hasSeenOnboarding, false);
      expect(state.completionReason, OnboardingCompletionReason.unknown);
    });

    test('markOnboardingSeen crea el modelo con los valores correctos y guarda con éxito', () async {
      final success = await repository.markOnboardingSeen(
        reason: OnboardingCompletionReason.skipped,
        lastStep: 3,
      );

      expect(success, true);
      expect(mockDataSource.lastSavedState, isNotNull);
      expect(mockDataSource.lastSavedState!.hasSeenOnboarding, true);
      expect(mockDataSource.lastSavedState!.completionReason, OnboardingCompletionReason.skipped);
      expect(mockDataSource.lastSavedState!.lastCompletedStep, 3);
      expect(mockDataSource.lastSavedState!.completedAtUtc, isNotNull);
    });

    test('markOnboardingSeen retorna false sin lanzar excepción ante fallo de almacenamiento (RF-8.2)', () async {
      mockDataSource.shouldThrow = true;

      final success = await repository.markOnboardingSeen(
        reason: OnboardingCompletionReason.completed,
        lastStep: 4,
      );

      expect(success, false);
    });
  });
}
