import '../../../core/errors/failures.dart';
import '../../../core/utils/either.dart';
import '../../repositories/auth_repository.dart';

/// Caso de uso para solicitar restablecimiento de contraseña
class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(String email) {
    return repository.resetPassword(email);
  }
}

