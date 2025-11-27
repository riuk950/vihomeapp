import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';
import '../entities/tenant.dart';

abstract class TenantRepository {
  Future<Either<Failure, Tenant?>> getTenantProfile(String userId);
  Future<Either<Failure, void>> saveTenantProfile(Tenant tenant);
}
