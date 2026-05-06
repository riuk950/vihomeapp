import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/domain/repositories/auth_repository.dart';

class UpdateUserRoleUseCase {
  final AuthRepository repository;

  UpdateUserRoleUseCase(this.repository);

  Future<Either<Failure, void>> call(String role) async {
    return await repository.updateUserRole(role);
  }
}
