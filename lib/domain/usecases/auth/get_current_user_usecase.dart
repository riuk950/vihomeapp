import '../../../core/errors/failures.dart';
import '../../../core/utils/either.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

/// Caso de uso para obtener el usuario actual
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, User?>> call() {
    return repository.getCurrentUser();
  }
}

