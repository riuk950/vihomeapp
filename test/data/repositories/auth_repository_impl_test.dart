import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/data/datasources/auth_remote_datasource.dart';
import 'package:vihomeapp/data/repositories/auth_repository_impl.dart';
import 'package:vihomeapp/domain/entities/user.dart' as entity;

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  bool deleteAccountCalled = false;
  Exception? exceptionToThrow;
  Failure? failureToThrow;

  @override
  Future<void> deleteAccount() async {
    deleteAccountCalled = true;
    if (failureToThrow != null) {
      throw failureToThrow!;
    }
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
  }

  @override
  Future<entity.User> signInWithEmail({required String email, required String password}) => throw UnimplementedError();
  @override
  Future<entity.User> signUp({required String email, required String password, Map<String, dynamic>? metadata}) => throw UnimplementedError();
  @override
  Future<void> signOut() => throw UnimplementedError();
  @override
  Future<void> resetPassword(String email) => throw UnimplementedError();
  @override
  Future<void> updatePassword(String newPassword) => throw UnimplementedError();
  @override
  Future<entity.User?> getCurrentUser() => throw UnimplementedError();
  @override
  Future<entity.User> signInWithGoogle() => throw UnimplementedError();
  @override
  Future<void> updateUserRole(String role) => throw UnimplementedError();
  @override
  Stream<entity.User?> authStateChanges() => throw UnimplementedError();
}

void main() {
  late FakeAuthRemoteDataSource fakeRemoteDataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    fakeRemoteDataSource = FakeAuthRemoteDataSource();
    repository = AuthRepositoryImpl(fakeRemoteDataSource);
  });

  group('AuthRepositoryImpl.deleteAccount [RF-55, DT-2]', () {
    test('debe retornar Right(null) cuando el datasource elimina exitosamente', () async {
      final result = await repository.deleteAccount();

      expect(fakeRemoteDataSource.deleteAccountCalled, isTrue);
      expect(result.isRight, isTrue);
    });

    test('debe retornar Left(Failure) cuando el datasource lanza una Failure conocida', () async {
      fakeRemoteDataSource.failureToThrow = const AuthFailure('Permiso denegado');

      final result = await repository.deleteAccount();

      expect(fakeRemoteDataSource.deleteAccountCalled, isTrue);
      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure.message, 'Permiso denegado'),
        (_) => fail('Se esperaba Left'),
      );
    });

    test('debe retornar Left(Failure) mapeada con AppErrorHandler cuando ocurre un error genérico', () async {
      fakeRemoteDataSource.exceptionToThrow = Exception('Error de conexión a la base de datos');

      final result = await repository.deleteAccount();

      expect(fakeRemoteDataSource.deleteAccountCalled, isTrue);
      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('Se esperaba Left'),
      );
    });
  });
}
