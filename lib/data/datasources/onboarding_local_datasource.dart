import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/storage_keys.dart';
import '../models/onboarding_state_model.dart';

/// Fuente de datos local para la persistencia del estado de onboarding.
abstract class OnboardingLocalDataSource {
  Future<OnboardingStateModel> getOnboardingState();
  Future<bool> saveOnboardingState(OnboardingStateModel state);
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final SharedPreferences sharedPreferences;

  OnboardingLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<OnboardingStateModel> getOnboardingState() async {
    try {
      final raw = sharedPreferences.getString(kOnboardingStateKey);
      return OnboardingStateModel.fromRawJson(raw);
    } catch (e) {
      debugPrint('[OnboardingLocalDataSource] Error al leer estado de onboarding: $e');
      return OnboardingStateModel.notSeen();
    }
  }

  @override
  Future<bool> saveOnboardingState(OnboardingStateModel state) async {
    try {
      final jsonStr = state.toRawJson();
      return await sharedPreferences.setString(kOnboardingStateKey, jsonStr);
    } catch (e) {
      debugPrint('[OnboardingLocalDataSource] Error al guardar estado de onboarding: $e');
      return false;
    }
  }
}
