import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/domain/entities/user.dart';
import 'package:vihomeapp/domain/repositories/auth_repository.dart';
import 'package:vihomeapp/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/reset_password_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_in_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_in_with_google_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_out_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_up_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/update_user_role_usecase.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';

class MockAuthRepo implements AuthRepository {
  User? currentUser;
  Failure? failure;

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    if (failure != null) return Left(failure!);
    return Right(currentUser);
  }

  @override
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (failure != null) return Left(failure!);
    if (email == 'user@vihome.app' && password == 'pass123') {
      final u = User(id: 'usr_1', email: email, name: 'Test User');
      currentUser = u;
      return Right(u);
    }
    return const Left(AuthFailure('Credenciales inválidas'));
  }

  @override
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    if (failure != null) return Left(failure!);
    final u = User(id: 'usr_new', email: email, role: metadata?['role']);
    currentUser = u;
    return Right(u);
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    if (failure != null) return Left(failure!);
    currentUser = null;
    return const Right(null);
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async =>
      const Left(AuthFailure('Google auth no implementado'));

  @override
  Future<Either<Failure, void>> resetPassword(String email) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updatePassword(String newPassword) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateUserRole(String role) async =>
      const Right(null);

  @override
  Stream<Either<Failure, User?>> authStateChanges() =>
      Stream.value(Right(currentUser));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepo mockRepo;
  late AuthProvider authProvider;

  setUp(() {
    mockRepo = MockAuthRepo();
    authProvider = AuthProvider(
      getCurrentUserUseCase: GetCurrentUserUseCase(mockRepo),
      signInUseCase: SignInUseCase(mockRepo),
      signInWithGoogleUseCase: SignInWithGoogleUseCase(mockRepo),
      signUpUseCase: SignUpUseCase(mockRepo),
      signOutUseCase: SignOutUseCase(mockRepo),
      resetPasswordUseCase: ResetPasswordUseCase(mockRepo),
      updateUserRoleUseCase: UpdateUserRoleUseCase(mockRepo),
    );
  });

  group('AuthProvider State Management Tests [RF-01]', () {
    test('initial state should be unauthenticated when no user exists [RF-01.1]', () {
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.user, isNull);
    });

    test('signInWithEmail should authenticate user on valid credentials [RF-01.1]', () async {
      final success = await authProvider.signInWithEmail(
        email: 'user@vihome.app',
        password: 'pass123',
      );

      expect(success, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.user?.email, 'user@vihome.app');
      expect(authProvider.errorMessage, isNull);
    });

    test('signInWithEmail should set errorMessage on bad credentials [RF-01.2]', () async {
      final success = await authProvider.signInWithEmail(
        email: 'user@vihome.app',
        password: 'wrongpass',
      );

      expect(success, isFalse);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.errorMessage, contains('Credenciales'));
    });

    test('signUp should authenticate user with provided role [RF-01.1]', () async {
      final success = await authProvider.signUp(
        email: 'landlord@vihome.app',
        password: 'securePass123',
        metadata: {'role': 'arrendador'},
      );

      expect(success, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.user?.role, 'arrendador');
    });

    test('signOut should set state back to unauthenticated [RF-01.1]', () async {
      await authProvider.signInWithEmail(
        email: 'user@vihome.app',
        password: 'pass123',
      );
      expect(authProvider.isAuthenticated, isTrue);

      await authProvider.signOut();
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.user, isNull);
    });
  });
}
