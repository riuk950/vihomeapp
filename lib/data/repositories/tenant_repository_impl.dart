import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';
import '../../domain/entities/tenant.dart';
import '../../domain/repositories/tenant_repository.dart';
import '../datasources/tenant_remote_datasource.dart';
import '../models/tenant_model.dart';

class TenantRepositoryImpl implements TenantRepository {
  final TenantRemoteDataSource remoteDataSource;

  TenantRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Tenant?>> getTenantProfile(String userId) async {
    try {
      final tenant = await remoteDataSource.getTenantProfile(userId);
      return Right(tenant);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveTenantProfile(Tenant tenant) async {
    try {
      await remoteDataSource.saveTenantProfile(TenantModel.fromEntity(tenant));
      return const Right(null);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
