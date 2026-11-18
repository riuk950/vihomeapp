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

class _StubAuthRepository implements AuthRepository {
  User? initialUser;
  bool throwOnGetCurrentUser;
  bool failSignOut;
  bool failDeleteAccount;

  _StubAuthRepository({
    this.initialUser,
    this.throwOnGetCurrentUser = false,
    this.failSignOut = false,
    this.failDeleteAccount = false,
  });

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    if (throwOnGetCurrentUser) {
      throw Exception('Token expirado o fallo de verificación');
    }
    return Right(initialUser);
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    if (failSignOut) {
      return const Left(NetworkFailure('Sin conexión al cerrar sesión'));
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    if (failDeleteAccount) {
      return const Left(ServerFailure('Error eliminando cuenta'));
    }
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AuthProvider _buildProvider(_StubAuthRepository repo) {
  return AuthProvider(
    getCurrentUserUseCase: GetCurrentUserUseCase(repo),
    signInUseCase: SignInUseCase(repo),
    signInWithGoogleUseCase: SignInWithGoogleUseCase(repo),
    signUpUseCase: SignUpUseCase(repo),
    signOutUseCase: SignOutUseCase(repo),
    deleteAccountUseCase: DeleteAccountUseCase(repo),
    resetPasswordUseCase: ResetPasswordUseCase(repo),
    updateUserRoleUseCase: UpdateUserRoleUseCase(repo),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthProvider - Estado Invitado y Ciclo de Sesión (RF-1.5..RF-1.7, RF-7.3..RF-7.5)', () {
    test('Inicialización sin usuario establece isGuest=true e isAuthenticated=false', () async {
      final provider = _buildProvider(_StubAuthRepository(initialUser: null));
      await Future<void>.delayed(Duration.zero);

      expect(provider.isInitialized, isTrue);
      expect(provider.isAuthenticated, isFalse);
      expect(provider.isGuest, isTrue);
    });

    test('Excepción al verificar sesión durante arranque entra de forma segura en modo invitado (RF-1.5, RF-1.6)', () async {
      final provider = _buildProvider(
        _StubAuthRepository(throwOnGetCurrentUser: true),
      );
      await Future<void>.delayed(Duration.zero);

      expect(provider.isInitialized, isTrue);
      expect(provider.isAuthenticated, isFalse);
      expect(provider.isGuest, isTrue);
    });

    test('handleSessionExpired pasa de autenticado a invitado marcando hasExpiredSession (RF-1.7)', () async {
      final provider = _buildProvider(
        _StubAuthRepository(
          initialUser: const User(id: 'u1', email: 'a@b.com', role: 'arrendatario'),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(provider.isAuthenticated, isTrue);

      provider.handleSessionExpired();
      expect(provider.isAuthenticated, isFalse);
      expect(provider.isGuest, isTrue);
      expect(provider.hasExpiredSession, isTrue);

      provider.consumeSessionExpiredFlag();
      expect(provider.hasExpiredSession, isFalse);
    });

    test('signOut con fallo de red limpia caché preservando onboarding y pasa a modo invitado (RF-7.3)', () async {
      SharedPreferences.setMockInitialValues({
        kOnboardingStateKey: '{"hasSeenOnboarding":true}',
        'some_private_cache': 'secret',
      });
      final provider = _buildProvider(
        _StubAuthRepository(
          initialUser: const User(id: 'u1', email: 'a@b.com', role: 'arrendador'),
          failSignOut: true,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      await provider.signOut();

      final prefs = await SharedPreferences.getInstance();
      expect(provider.isGuest, isTrue);
      expect(prefs.getString(kOnboardingStateKey), '{"hasSeenOnboarding":true}');
      expect(prefs.getString('some_private_cache'), isNull);
    });

    test('deleteAccount fallido conserva la sesión activa intacta (RF-7.5)', () async {
      final provider = _buildProvider(
        _StubAuthRepository(
          initialUser: const User(id: 'u1', email: 'a@b.com', role: 'arrendatario'),
          failDeleteAccount: true,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      final result = await provider.deleteAccount();

      expect(result, isFalse);
      expect(provider.isAuthenticated, isTrue);
      expect(provider.isGuest, isFalse);
    });
  });
}
