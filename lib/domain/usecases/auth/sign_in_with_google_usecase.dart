import '../../../core/errors/failures.dart';
import '../../../core/utils/either.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

/// Caso de uso para iniciar sesión con Google
class SignInWithGoogleUseCase {
  final AuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  Future<Either<Failure, User>> call() {
    return repository.signInWithGoogle();
  }
}
