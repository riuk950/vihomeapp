import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vihomeapp/core/constants/storage_keys.dart';
import 'package:vihomeapp/data/datasources/onboarding_local_datasource.dart';
import 'package:vihomeapp/data/models/onboarding_state_model.dart';
import 'package:vihomeapp/domain/entities/onboarding_state.dart';

void main() {
  group('OnboardingLocalDataSourceImpl', () {
    test('getOnboardingState retorna notSeen cuando la clave no existe en SharedPreferences (RF-1.1)', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final dataSource = OnboardingLocalDataSourceImpl(sharedPreferences: prefs);

      final result = await dataSource.getOnboardingState();
      expect(result.hasSeenOnboarding, false);
      expect(result.completionReason, OnboardingCompletionReason.unknown);
    });

    test('getOnboardingState retorna el modelo correcto cuando existe en SharedPreferences (RF-7.1)', () async {
      SharedPreferences.setMockInitialValues({
        kOnboardingStateKey: '''
        {
          "schemaVersion": 1,
          "hasSeenOnboarding": true,
          "completionReason": "completed",
          "lastCompletedStep": 4,
          "completedAtUtc": "2026-11-18T14:45:00.000Z"
        }
        ''',
      });
      final prefs = await SharedPreferences.getInstance();
      final dataSource = OnboardingLocalDataSourceImpl(sharedPreferences: prefs);

      final result = await dataSource.getOnboardingState();
      expect(result.hasSeenOnboarding, true);
      expect(result.completionReason, OnboardingCompletionReason.completed);
      expect(result.lastCompletedStep, 4);
    });

    test('saveOnboardingState persiste la cadena JSON en SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final dataSource = OnboardingLocalDataSourceImpl(sharedPreferences: prefs);

      const model = OnboardingStateModel(
        schemaVersion: 1,
        hasSeenOnboarding: true,
        completionReason: OnboardingCompletionReason.skipped,
        lastCompletedStep: 2,
      );

      final saved = await dataSource.saveOnboardingState(model);
      expect(saved, true);

      final raw = prefs.getString(kOnboardingStateKey);
      expect(raw, contains('"hasSeenOnboarding":true'));
      expect(raw, contains('"completionReason":"skipped"'));
    });
  });
}
