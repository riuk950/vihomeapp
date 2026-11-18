import 'package:flutter/foundation.dart';
import '../../domain/entities/onboarding_state.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';
import '../models/onboarding_state_model.dart';

/// Implementación del repositorio de onboarding garantizando resiliencia y no bloqueo ante fallos.
class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource localDataSource;

  OnboardingRepositoryImpl({required this.localDataSource});

  @override
  Future<OnboardingState> getOnboardingState() async {
    try {
      return await localDataSource.getOnboardingState();
    } catch (e) {
      debugPrint('[OnboardingRepositoryImpl] Fallo no fatal al consultar estado de onboarding: $e');
      return OnboardingState.notSeen();
    }
  }

  @override
  Future<bool> markOnboardingSeen({
    required OnboardingCompletionReason reason,
    required int lastStep,
  }) async {
    try {
      final model = OnboardingStateModel(
        schemaVersion: 1,
        hasSeenOnboarding: true,
        completionReason: reason,
        lastCompletedStep: lastStep,
        completedAtUtc: DateTime.now().toUtc(),
      );
      return await localDataSource.saveOnboardingState(model);
    } catch (e) {
      debugPrint('[OnboardingRepositoryImpl] Fallo no fatal al guardar estado visto: $e');
      return false;
    }
  }
}
