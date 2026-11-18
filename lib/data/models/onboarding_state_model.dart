import 'dart:convert';
import '../../domain/entities/onboarding_state.dart';

/// Modelo de datos para la serialización y persistencia del estado del onboarding.
class OnboardingStateModel extends OnboardingState {
  final int schemaVersion;

  const OnboardingStateModel({
    this.schemaVersion = 1,
    required super.hasSeenOnboarding,
    required super.completionReason,
    required super.lastCompletedStep,
    super.completedAtUtc,
  });

  factory OnboardingStateModel.notSeen() {
    return const OnboardingStateModel(
      schemaVersion: 1,
      hasSeenOnboarding: false,
      completionReason: OnboardingCompletionReason.unknown,
      lastCompletedStep: 0,
      completedAtUtc: null,
    );
  }

  factory OnboardingStateModel.fromEntity(OnboardingState entity) {
    return OnboardingStateModel(
      schemaVersion: 1,
      hasSeenOnboarding: entity.hasSeenOnboarding,
      completionReason: entity.completionReason,
      lastCompletedStep: entity.lastCompletedStep,
      completedAtUtc: entity.completedAtUtc,
    );
  }

  factory OnboardingStateModel.fromJson(Map<String, dynamic> json) {
    try {
      final schemaVersion = json['schemaVersion'] as int? ?? 1;
      final hasSeen = json['hasSeenOnboarding'] as bool? ?? false;
      final reasonStr = json['completionReason'] as String?;
      final lastStep = json['lastCompletedStep'] as int? ?? 0;
      final dateStr = json['completedAtUtc'] as String?;
      final completedAt = dateStr != null ? DateTime.tryParse(dateStr) : null;

      return OnboardingStateModel(
        schemaVersion: schemaVersion,
        hasSeenOnboarding: hasSeen,
        completionReason: OnboardingCompletionReason.fromString(reasonStr),
        lastCompletedStep: lastStep,
        completedAtUtc: completedAt,
      );
    } catch (_) {
      return OnboardingStateModel.notSeen();
    }
  }

  factory OnboardingStateModel.fromRawJson(String? rawJson) {
    if (rawJson == null || rawJson.trim().isEmpty) {
      return OnboardingStateModel.notSeen();
    }
    try {
      final decoded = json.decode(rawJson);
      if (decoded is Map<String, dynamic>) {
        return OnboardingStateModel.fromJson(decoded);
      }
      return OnboardingStateModel.notSeen();
    } catch (_) {
      return OnboardingStateModel.notSeen();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'hasSeenOnboarding': hasSeenOnboarding,
      'completionReason': completionReason.toSerializedString(),
      'lastCompletedStep': lastCompletedStep,
      'completedAtUtc': completedAtUtc?.toUtc().toIso8601String(),
    };
  }

  String toRawJson() => json.encode(toJson());
}
