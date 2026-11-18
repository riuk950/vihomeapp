/// Razón por la cual se completó u omitió el onboarding.
enum OnboardingCompletionReason {
  completed,
  skipped,
  loginShortcut,
  existingSession,
  unknown;

  static OnboardingCompletionReason fromString(String? value) {
    switch (value) {
      case 'completed':
        return OnboardingCompletionReason.completed;
      case 'skipped':
        return OnboardingCompletionReason.skipped;
      case 'login_shortcut':
        return OnboardingCompletionReason.loginShortcut;
      case 'existing_session':
        return OnboardingCompletionReason.existingSession;
      default:
        return OnboardingCompletionReason.unknown;
    }
  }

  String toSerializedString() {
    switch (this) {
      case OnboardingCompletionReason.completed:
        return 'completed';
      case OnboardingCompletionReason.skipped:
        return 'skipped';
      case OnboardingCompletionReason.loginShortcut:
        return 'login_shortcut';
      case OnboardingCompletionReason.existingSession:
        return 'existing_session';
      case OnboardingCompletionReason.unknown:
        return 'unknown';
    }
  }
}

/// Entidad inmutable que representa el estado persistido de visualización del onboarding.
class OnboardingState {
  final bool hasSeenOnboarding;
  final OnboardingCompletionReason completionReason;
  final int lastCompletedStep;
  final DateTime? completedAtUtc;

  const OnboardingState({
    required this.hasSeenOnboarding,
    required this.completionReason,
    required this.lastCompletedStep,
    this.completedAtUtc,
  });

  /// Estado por defecto cuando el usuario no ha visto el onboarding.
  factory OnboardingState.notSeen() {
    return const OnboardingState(
      hasSeenOnboarding: false,
      completionReason: OnboardingCompletionReason.unknown,
      lastCompletedStep: 0,
      completedAtUtc: null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingState &&
          runtimeType == other.runtimeType &&
          hasSeenOnboarding == other.hasSeenOnboarding &&
          completionReason == other.completionReason &&
          lastCompletedStep == other.lastCompletedStep &&
          completedAtUtc == other.completedAtUtc;

  @override
  int get hashCode =>
      hasSeenOnboarding.hashCode ^
      completionReason.hashCode ^
      lastCompletedStep.hashCode ^
      completedAtUtc.hashCode;
}
