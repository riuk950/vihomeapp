import '../../../core/errors/failures.dart';
import '../../../core/utils/either.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

/// Caso de uso para registrar un nuevo usuario
class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) {
    return repository.signUp(
      email: email,
      password: password,
      metadata: metadata,
    );
  }
}

