import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/domain/entities/user.dart';
import 'package:vihomeapp/domain/repositories/auth_repository.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_in_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_up_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_out_usecase.dart';

class FakeAuthRepository implements AuthRepository {
  User? currentUser;
  Failure? failureToReturn;

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    if (failureToReturn != null) return Left(failureToReturn!);
    return Right(currentUser);
  }

  @override
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (failureToReturn != null) return Left(failureToReturn!);
    if (email == 'valid@vihome.app' && password == '123456') {
      final user = User(id: 'usr_1', email: email, name: 'Usuario Valido');
      currentUser = user;
      return Right(user);
    }
    return const Left(AuthFailure('Credenciales inválidas'));
  }

  @override
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    if (failureToReturn != null) return Left(failureToReturn!);
    final user = User(
      id: 'usr_new',
      email: email,
      name: metadata?['name'] as String?,
      role: metadata?['role'] as String? ?? 'arrendatario',
    );
    currentUser = user;
    return Right(user);
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    if (failureToReturn != null) return Left(failureToReturn!);
    currentUser = null;
    return const Right(null);
  }

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
  Future<Either<Failure, void>> updateUserRole(String role) async =>
      throw UnimplementedError();

  @override
  Stream<Either<Failure, User?>> authStateChanges() =>
      Stream.value(Right(currentUser));
}

void main() {
  late FakeAuthRepository fakeRepository;
  late SignInUseCase signInUseCase;
  late SignUpUseCase signUpUseCase;
  late GetCurrentUserUseCase getCurrentUserUseCase;
  late SignOutUseCase signOutUseCase;

  setUp(() {
    fakeRepository = FakeAuthRepository();
    signInUseCase = SignInUseCase(fakeRepository);
    signUpUseCase = SignUpUseCase(fakeRepository);
    getCurrentUserUseCase = GetCurrentUserUseCase(fakeRepository);
    signOutUseCase = SignOutUseCase(fakeRepository);
  });

  group('Auth UseCases Tests [RF-01]', () {
    test('SignInUseCase should return User on valid email and password [RF-01.1]', () async {
      final result = await signInUseCase(
        email: 'valid@vihome.app',
        password: '123456',
      );

      expect(result.isRight, isTrue);
      result.fold(
        (failure) => fail('Should not fail'),
        (user) {
          expect(user.email, 'valid@vihome.app');
          expect(user.id, 'usr_1');
        },
      );
    });

    test('SignInUseCase should return AuthFailure on invalid credentials [RF-01.2]', () async {
      final result = await signInUseCase(
        email: 'wrong@vihome.app',
        password: 'wrongpass',
      );

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
          expect(failure.message, 'Credenciales inválidas');
        },
        (user) => fail('Should not succeed'),
      );
    });

    test('SignUpUseCase should register and return newly created User [RF-01.1]', () async {
      final result = await signUpUseCase(
        email: 'nuevo@vihome.app',
        password: 'password123',
        metadata: {
          'name': 'Nuevo Arrendador',
          'role': 'arrendador',
        },
      );

      expect(result.isRight, isTrue);
      result.fold(
        (failure) => fail('Should not fail'),
        (user) {
          expect(user.email, 'nuevo@vihome.app');
          expect(user.role, 'arrendador');
        },
      );
    });

    test('GetCurrentUserUseCase should return authenticated user or null [RF-01.1]', () async {
      expect((await getCurrentUserUseCase()).fold((l) => null, (r) => r), isNull);

      fakeRepository.currentUser = const User(id: 'usr_active', email: 'activo@vihome.app');
      final result = await getCurrentUserUseCase();

      expect(result.isRight, isTrue);
      expect(result.fold((l) => null, (r) => r)?.id, 'usr_active');
    });

    test('SignOutUseCase should clear current session [RF-01.1]', () async {
      fakeRepository.currentUser = const User(id: 'usr_active', email: 'activo@vihome.app');
      final result = await signOutUseCase();

      expect(result.isRight, isTrue);
      expect(fakeRepository.currentUser, isNull);
    });
  });
}
