import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/data/models/onboarding_state_model.dart';
import 'package:vihomeapp/domain/entities/onboarding_state.dart';

void main() {
  group('OnboardingStateModel', () {
    final tDateTime = DateTime.parse('2026-11-18T14:45:00.000Z');

    const tModel = OnboardingStateModel(
      schemaVersion: 1,
      hasSeenOnboarding: true,
      completionReason: OnboardingCompletionReason.completed,
      lastCompletedStep: 4,
    );

    test('debe ser un subtipo de la entidad OnboardingState', () {
      expect(tModel, isA<OnboardingState>());
    });

    test('notSeen() debe retornar estado no visto con valores por defecto', () {
      final notSeen = OnboardingStateModel.notSeen();
      expect(notSeen.hasSeenOnboarding, false);
      expect(notSeen.completionReason, OnboardingCompletionReason.unknown);
      expect(notSeen.lastCompletedStep, 0);
      expect(notSeen.completedAtUtc, isNull);
    });

    test('toJson y fromJson deben serializar y deserializar correctamente', () {
      final modelWithDate = OnboardingStateModel(
        schemaVersion: 1,
        hasSeenOnboarding: true,
        completionReason: OnboardingCompletionReason.skipped,
        lastCompletedStep: 2,
        completedAtUtc: tDateTime,
      );

      final jsonMap = modelWithDate.toJson();
      expect(jsonMap['schemaVersion'], 1);
      expect(jsonMap['hasSeenOnboarding'], true);
      expect(jsonMap['completionReason'], 'skipped');
      expect(jsonMap['lastCompletedStep'], 2);
      expect(jsonMap['completedAtUtc'], '2026-11-18T14:45:00.000Z');

      final deserialized = OnboardingStateModel.fromJson(jsonMap);
      expect(deserialized.hasSeenOnboarding, true);
      expect(deserialized.completionReason, OnboardingCompletionReason.skipped);
      expect(deserialized.lastCompletedStep, 2);
      expect(deserialized.completedAtUtc, tDateTime);
    });

    test('fromRawJson debe parsear un string JSON válido', () {
      const rawJson = '''
      {
        "schemaVersion": 1,
        "hasSeenOnboarding": true,
        "completionReason": "login_shortcut",
        "lastCompletedStep": 1,
        "completedAtUtc": "2026-11-18T14:45:00.000Z"
      }
      ''';

      final model = OnboardingStateModel.fromRawJson(rawJson);
      expect(model.hasSeenOnboarding, true);
      expect(model.completionReason, OnboardingCompletionReason.loginShortcut);
      expect(model.lastCompletedStep, 1);
    });

    test('fromRawJson debe ser tolerante ante JSON corrupto, nulo o vacío (RF-8.3)', () {
      expect(OnboardingStateModel.fromRawJson(null).hasSeenOnboarding, false);
      expect(OnboardingStateModel.fromRawJson('').hasSeenOnboarding, false);
      expect(OnboardingStateModel.fromRawJson('{invalid_json').hasSeenOnboarding, false);
      expect(OnboardingStateModel.fromRawJson('[]').hasSeenOnboarding, false);
    });

    test('fromEntity debe convertir una entidad OnboardingState a modelo', () {
      final entity = OnboardingState(
        hasSeenOnboarding: true,
        completionReason: OnboardingCompletionReason.existingSession,
        lastCompletedStep: 0,
        completedAtUtc: tDateTime,
      );

      final model = OnboardingStateModel.fromEntity(entity);
      expect(model.hasSeenOnboarding, true);
      expect(model.completionReason, OnboardingCompletionReason.existingSession);
      expect(model.lastCompletedStep, 0);
      expect(model.completedAtUtc, tDateTime);
    });
  });
}
