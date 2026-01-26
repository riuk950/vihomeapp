import '../../../core/errors/failures.dart';
import '../../../core/utils/either.dart';
import '../../repositories/auth_repository.dart';

/// Caso de uso para cerrar sesión
class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.signOut();
  }
}

