import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/domain/entities/tenant.dart';
import 'package:vihomeapp/domain/repositories/tenant_repository.dart';

class GetTenantProfileUseCase {
  final TenantRepository repository;

  GetTenantProfileUseCase(this.repository);

  Future<Either<Failure, Tenant?>> call(String userId) {
    return repository.getTenantProfile(userId);
  }
}
