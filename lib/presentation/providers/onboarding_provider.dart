import 'package:flutter/foundation.dart';
import '../../domain/entities/onboarding_state.dart';
import '../../domain/entities/onboarding_step.dart';
import '../../domain/usecases/onboarding/complete_onboarding_usecase.dart';
import '../../domain/usecases/onboarding/get_onboarding_status_usecase.dart';

/// Proveedor de estado para controlar la navegación, progreso y finalización del onboarding.
class OnboardingProvider extends ChangeNotifier {
  final GetOnboardingStatusUseCase getOnboardingStatusUseCase;
  final CompleteOnboardingUseCase completeOnboardingUseCase;

  int _currentPage = 0;
  bool _isExiting = false;
  bool _isTransitioning = false;

  OnboardingProvider({
    required this.getOnboardingStatusUseCase,
    required this.completeOnboardingUseCase,
  });

  /// Pasos inmutables de la guía de bienvenida.
  List<OnboardingStep> get steps => OnboardingStep.defaultSteps;
  int get totalSteps => steps.length;

  int get currentPage => _currentPage;
  bool get isFirstStep => _currentPage == 0;
  bool get isLastStep => _currentPage == totalSteps - 1;
  bool get isExiting => _isExiting;
  bool get isTransitioning => _isTransitioning;

  OnboardingStep get currentStep => steps[_currentPage];

  /// Actualiza el índice del paso actual cuando el usuario desliza la página.
  void setPage(int page) {
    if (page >= 0 && page < totalSteps && _currentPage != page) {
      _currentPage = page;
      notifyListeners();
    }
  }

  /// Avanza un paso hacia adelante si no se encuentra en el último paso.
  /// Retorna `true` si avanza; `false` si ya está en el último paso o en transición.
  bool goToNextStep() {
    if (_isTransitioning || _isExiting) return false;
    if (_currentPage < totalSteps - 1) {
      _isTransitioning = true;
      _currentPage++;
      notifyListeners();
      _isTransitioning = false;
      return true;
    }
    return false;
  }

  /// Retrocede un paso hacia atrás si no se encuentra en el primer paso.
  /// Retorna `true` si retrocede; `false` si ya está en el primer paso o en transición.
  bool goToPreviousStep() {
    if (_isTransitioning || _isExiting) return false;
    if (_currentPage > 0) {
      _isTransitioning = true;
      _currentPage--;
      notifyListeners();
      _isTransitioning = false;
      return true;
    }
    return false;
  }

  /// Registra el onboarding como completado u omitido y prepara la salida hacia el login.
  /// Protegido con guarda `_isExiting` contra toques dobles o concurrentes.
  /// Siempre autoriza la navegación (`true`) para no bloquear al usuario ante fallos de persistencia.
  Future<bool> exitOnboarding(OnboardingCompletionReason reason) async {
    if (_isExiting) return false;
    _isExiting = true;
    notifyListeners();

    try {
      await completeOnboardingUseCase(
        reason: reason,
        step: _currentPage + 1,
      );
    } catch (e) {
      debugPrint('[OnboardingProvider] Error al registrar salida del onboarding: $e');
    }

    return true;
  }

  /// Resetea el estado interno (utilizado principalmente en pruebas).
  void reset() {
    _currentPage = 0;
    _isExiting = false;
    _isTransitioning = false;
    notifyListeners();
  }
}
