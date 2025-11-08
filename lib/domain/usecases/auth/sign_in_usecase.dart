import '../../../core/errors/failures.dart';
import '../../../core/utils/either.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

/// Caso de uso para iniciar sesión
class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) {
    return repository.signInWithEmail(
      email: email,
      password: password,
    );
  }
}

