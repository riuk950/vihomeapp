import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/domain/entities/onboarding_state.dart';
import 'package:vihomeapp/domain/repositories/onboarding_repository.dart';
import 'package:vihomeapp/domain/usecases/onboarding/complete_onboarding_usecase.dart';
import 'package:vihomeapp/domain/usecases/onboarding/get_onboarding_status_usecase.dart';
import 'package:vihomeapp/presentation/providers/onboarding_provider.dart';

class MockOnboardingRepo implements OnboardingRepository {
  int markCalls = 0;
  OnboardingCompletionReason? lastReason;
  int? lastStep;
  bool returnSuccess = true;

  @override
  Future<OnboardingState> getOnboardingState() async => OnboardingState.notSeen();

  @override
  Future<bool> markOnboardingSeen({
    required OnboardingCompletionReason reason,
    required int lastStep,
  }) async {
    markCalls++;
    lastReason = reason;
    this.lastStep = lastStep;
    return returnSuccess;
  }
}

void main() {
  late MockOnboardingRepo mockRepo;
  late OnboardingProvider provider;

  setUp(() {
    mockRepo = MockOnboardingRepo();
    provider = OnboardingProvider(
      getOnboardingStatusUseCase: GetOnboardingStatusUseCase(mockRepo),
      completeOnboardingUseCase: CompleteOnboardingUseCase(mockRepo),
    );
  });

  group('OnboardingProvider', () {
    test('inicia en el paso 0 con 4 pasos y banderas iniciales correctas', () {
      expect(provider.currentPage, 0);
      expect(provider.totalSteps, 4);
      expect(provider.isFirstStep, true);
      expect(provider.isLastStep, false);
      expect(provider.isExiting, false);
      expect(provider.currentStep.title, 'Conecta con tu Espacio Ideal');
      expect(provider.currentStep.ctaLabel, 'Continuar');
    });

    test('goToNextStep avanza secuencialmente hasta el paso 4 y no excede límites (RF-3.1, RF-3.4)', () {
      expect(provider.goToNextStep(), true);
      expect(provider.currentPage, 1);
      expect(provider.isFirstStep, false);
      expect(provider.currentStep.title, 'Conexión Directa y Transparente');

      expect(provider.goToNextStep(), true);
      expect(provider.currentPage, 2);
      expect(provider.currentStep.title, 'Contratos Digitales Seguros');

      expect(provider.goToNextStep(), true);
      expect(provider.currentPage, 3);
      expect(provider.isLastStep, true);
      expect(provider.currentStep.title, 'Gestión Integral Sin Fricción');
      expect(provider.currentStep.ctaLabel, 'Comenzar Ahora');

      // Intentar avanzar más allá del paso 4 debe retornar false
      expect(provider.goToNextStep(), false);
      expect(provider.currentPage, 3);
    });

    test('goToPreviousStep retrocede secuencialmente y bloquea retroceso en paso 1 (RF-3.2, RF-3.3)', () {
      provider.setPage(3);
      expect(provider.currentPage, 3);

      expect(provider.goToPreviousStep(), true);
      expect(provider.currentPage, 2);

      expect(provider.goToPreviousStep(), true);
      expect(provider.currentPage, 1);

      expect(provider.goToPreviousStep(), true);
      expect(provider.currentPage, 0);
      expect(provider.isFirstStep, true);

      // En paso 0 no debe permitir retroceder
      expect(provider.goToPreviousStep(), false);
      expect(provider.currentPage, 0);
    });

    test('exitOnboarding invoca caso de uso con la razón y paso correspondiente', () async {
      provider.setPage(3);
      final result = await provider.exitOnboarding(OnboardingCompletionReason.completed);

      expect(result, true);
      expect(mockRepo.markCalls, 1);
      expect(mockRepo.lastReason, OnboardingCompletionReason.completed);
      expect(mockRepo.lastStep, 4);
      expect(provider.isExiting, true);
    });

    test('guarda anti doble-toque: llamadas concurrentes solo ejecutan el guardado una vez (RF-3.7)', () async {
      final future1 = provider.exitOnboarding(OnboardingCompletionReason.skipped);
      final future2 = provider.exitOnboarding(OnboardingCompletionReason.skipped);

      final results = await Future.wait([future1, future2]);
      expect(results[0], true);
      expect(results[1], false); // Segunda llamada bloqueada por _isExiting
      expect(mockRepo.markCalls, 1);
    });

    test('exitOnboarding retorna true aun si el guardado falla para no bloquear al usuario (RF-8.2)', () async {
      mockRepo.returnSuccess = false;
      final result = await provider.exitOnboarding(OnboardingCompletionReason.loginShortcut);

      expect(result, true);
      expect(mockRepo.markCalls, 1);
      expect(mockRepo.lastReason, OnboardingCompletionReason.loginShortcut);
    });
  });
}
