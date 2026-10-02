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

class MockAuthRepoForRoleSwitch implements AuthRepository {
  User? currentUser;
  Failure? failure;
  int updateRoleCalls = 0;
  String? lastUpdatedRole;

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    if (failure != null) return Left(failure!);
    return Right(currentUser);
  }

  @override
  Future<Either<Failure, void>> updateUserRole(String role) async {
    updateRoleCalls++;
    lastUpdatedRole = role;
    if (failure != null) return Left(failure!);
    if (currentUser != null) {
      currentUser = currentUser!.copyWith(role: role);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> signOut() async => throw UnimplementedError();

  @override
  Future<Either<Failure, User>> signInWithGoogle() async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> resetPassword(String email) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> updatePassword(String newPassword) async =>
      throw UnimplementedError();

  @override
  Stream<Either<Failure, User?>> authStateChanges() =>
      Stream.value(Right(currentUser));
}

void main() {
  late MockAuthRepoForRoleSwitch mockRepo;
  late AuthProvider authProvider;

  setUp(() {
    mockRepo = MockAuthRepoForRoleSwitch();
    authProvider = AuthProvider(
      getCurrentUserUseCase: GetCurrentUserUseCase(mockRepo),
      signInUseCase: SignInUseCase(mockRepo),
      signUpUseCase: SignUpUseCase(mockRepo),
      signOutUseCase: SignOutUseCase(mockRepo),
      signInWithGoogleUseCase: SignInWithGoogleUseCase(mockRepo),
      resetPasswordUseCase: ResetPasswordUseCase(mockRepo),
      updateUserRoleUseCase: UpdateUserRoleUseCase(mockRepo),
    );
  });

  group('AuthProvider Role Switching Tests (HU-32, RF-37, RF-40)', () {
    test('becomeLandlord switches user role from arrendatario to arrendador', () async {
      final initialUser = const User(
        id: 'u1',
        email: 'test@vihome.app',
        name: 'Diego Villate',
        role: 'arrendatario',
      );
      mockRepo.currentUser = initialUser;
      await authProvider.reloadUser();

      expect(authProvider.user?.role, 'arrendatario');

      final success = await authProvider.becomeLandlord();

      expect(success, isTrue);
      expect(mockRepo.updateRoleCalls, 1);
      expect(mockRepo.lastUpdatedRole, 'arrendador');
      expect(authProvider.user?.role, 'arrendador');
    });

    test('becomeTenant switches user role from arrendador to arrendatario', () async {
      final initialUser = const User(
        id: 'u1',
        email: 'test@vihome.app',
        name: 'Diego Villate',
        role: 'arrendador',
      );
      mockRepo.currentUser = initialUser;
      await authProvider.reloadUser();

      expect(authProvider.user?.role, 'arrendador');

      final success = await authProvider.becomeTenant();

      expect(success, isTrue);
      expect(mockRepo.updateRoleCalls, 1);
      expect(mockRepo.lastUpdatedRole, 'arrendatario');
      expect(authProvider.user?.role, 'arrendatario');
    });

    test('switchRole does not invoke repo when user already has target role (CL-33)', () async {
      final initialUser = const User(
        id: 'u1',
        email: 'test@vihome.app',
        name: 'Diego Villate',
        role: 'arrendador',
      );
      mockRepo.currentUser = initialUser;
      await authProvider.reloadUser();

      final success = await authProvider.switchRole('arrendador');

      expect(success, isTrue);
      expect(mockRepo.updateRoleCalls, 0); // No redundancy
    });

    test('switchRole handles failure from use case gracefully', () async {
      final initialUser = const User(
        id: 'u1',
        email: 'test@vihome.app',
        name: 'Diego Villate',
        role: 'arrendatario',
      );
      mockRepo.currentUser = initialUser;
      await authProvider.reloadUser();

      mockRepo.failure = const ServerFailure('Error de red al actualizar rol');

      final success = await authProvider.becomeLandlord();

      expect(success, isFalse);
      expect(authProvider.errorMessage, contains('Error de red al actualizar rol'));
      expect(authProvider.user?.role, 'arrendatario'); // Rol no muta si falló
    });
  });
}
