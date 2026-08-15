import '../../core/errors/failures.dart';
import '../../core/errors/app_error_handler.dart';
import '../../core/utils/either.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementación del repositorio de autenticación
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signInWithEmail(
        email: email,
        password: password,
      );
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = await remoteDataSource.signUp(
        email: email,
        password: password,
        metadata: metadata,
      );
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final user = await remoteDataSource.signInWithGoogle();
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await remoteDataSource.resetPassword(email);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword(String newPassword) async {
    try {
      await remoteDataSource.updatePassword(newPassword);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserRole(String role) async {
    try {
      await remoteDataSource.updateUserRole(role);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppErrorHandler.handle(e));
    }
  }

  @override
  Stream<Either<Failure, User?>> authStateChanges() {
    try {
      return remoteDataSource.authStateChanges().map((user) {
        return Right<Failure, User?>(user);
      }).handleError((error) {
        return Left<Failure, User?>(AppErrorHandler.handle(error));
      });
    } catch (e) {
      return Stream.value(Left(AppErrorHandler.handle(e)));
    }
  }
}
