import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/domain/entities/tenant.dart';
import 'package:vihomeapp/domain/repositories/tenant_repository.dart';

class SaveTenantProfileUseCase {
  final TenantRepository repository;

  SaveTenantProfileUseCase(this.repository);

  Future<Either<Failure, void>> call(Tenant tenant) {
    return repository.saveTenantProfile(tenant);
  }
}
