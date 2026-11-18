import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vihomeapp/core/constants/storage_keys.dart';
import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/domain/entities/user.dart';
import 'package:vihomeapp/domain/repositories/auth_repository.dart';
import 'package:vihomeapp/domain/usecases/auth/delete_account_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/reset_password_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_in_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_in_with_google_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_out_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_up_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/update_user_role_usecase.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';

class FakeAuthRepository implements AuthRepository {
  User? user = const User(id: 'u1', email: 'test@vihome.com', name: 'Test');

  @override
  Future<Either<Failure, User?>> getCurrentUser() async => Right(user);

  @override
  Future<Either<Failure, void>> signOut() async {
    user = null;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    user = null;
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthRepository fakeRepo;
  late AuthProvider authProvider;

  setUp(() {
    fakeRepo = FakeAuthRepository();
    authProvider = AuthProvider(
      getCurrentUserUseCase: GetCurrentUserUseCase(fakeRepo),
      signInUseCase: SignInUseCase(fakeRepo),
      signInWithGoogleUseCase: SignInWithGoogleUseCase(fakeRepo),
      signUpUseCase: SignUpUseCase(fakeRepo),
      signOutUseCase: SignOutUseCase(fakeRepo),
      deleteAccountUseCase: DeleteAccountUseCase(fakeRepo),
      resetPasswordUseCase: ResetPasswordUseCase(fakeRepo),
      updateUserRoleUseCase: UpdateUserRoleUseCase(fakeRepo),
    );
  });

  group('Preservación del estado de Onboarding en AuthProvider (RF-7.3)', () {
    test('signOut() limpia la sesión pero PRESERVA intacta la clave del onboarding', () async {
      const onboardingJson = '{"schemaVersion":1,"hasSeenOnboarding":true,"completionReason":"completed","lastCompletedStep":4}';

      SharedPreferences.setMockInitialValues({
        kOnboardingStateKey: onboardingJson,
        'cached_user_token': 'secret_token_123',
        'some_other_preference': 'temp_value',
      });

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(kOnboardingStateKey), onboardingJson);
      expect(prefs.getString('cached_user_token'), 'secret_token_123');

      // Ejecutar signOut()
      await authProvider.signOut();

      // Verificar que los datos temporales se borraron pero el onboarding sigue intacto
      expect(prefs.getString(kOnboardingStateKey), onboardingJson);
      expect(prefs.getString('cached_user_token'), isNull);
      expect(prefs.getString('some_other_preference'), isNull);
    });

    test('deleteAccount() limpia la caché pero PRESERVA intacta la clave del onboarding', () async {
      const onboardingJson = '{"schemaVersion":1,"hasSeenOnboarding":true,"completionReason":"skipped","lastCompletedStep":2}';

      SharedPreferences.setMockInitialValues({
        kOnboardingStateKey: onboardingJson,
        'cached_user_token': 'secret_token_123',
      });

      final prefs = await SharedPreferences.getInstance();

      // Ejecutar deleteAccount()
      final result = await authProvider.deleteAccount();
      expect(result, true);

      // Verificar que el onboarding sigue presente
      expect(prefs.getString(kOnboardingStateKey), onboardingJson);
      expect(prefs.getString('cached_user_token'), isNull);
    });
  });
}
