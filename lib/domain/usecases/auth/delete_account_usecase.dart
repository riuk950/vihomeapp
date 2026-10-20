import '../../../core/errors/failures.dart';
import '../../../core/utils/either.dart';
import '../../repositories/auth_repository.dart';

/// Caso de uso para eliminar definitivamente la cuenta del usuario autenticado
/// y realizar la limpieza en cascada de sus datos asociados.
class DeleteAccountUseCase {
  final AuthRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.deleteAccount();
  }
}
