import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/either.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/property.dart';
import '../../domain/entities/property_type.dart';
import '../../domain/repositories/property_repository.dart';
import '../datasources/property_remote_datasource.dart';
import '../datasources/property_local_datasource.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyRemoteDataSource remoteDataSource;
  final PropertyLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PropertyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Property>>> getProperties() async {
    if (await networkInfo.isConnected) {
      try {
        final properties = await remoteDataSource.getProperties();
        await localDataSource.cacheProperties(properties);
        return Right(properties);
      } on ServerFailure catch (e) {
        return Left(e);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final localProperties = await localDataSource.getLastProperties();
        return Right(localProperties);
      } on CacheException {
        return Left(CacheFailure('No cached data present'));
      }
    }
  }

  @override
  Future<Either<Failure, List<Property>>> getPropertiesByLandlord(
    String landlordId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final properties = await remoteDataSource.getPropertiesByLandlord(
          landlordId,
        );
        // data persistence for landlord properties could be added here if needed
        return Right(properties);
      } on ServerFailure catch (e) {
        return Left(e);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      // Ideally we would search in the cached list or have a specific cache,
      // but for now we fallback to empty or error if strict.
      // Let's return error for now or try to filter from main cache if pertinent.
      // For simplicity, let's keep it online-only or simple fail.
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Property>> createProperty(
    Map<String, dynamic> propertyData,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final property = await remoteDataSource.createProperty(propertyData);
        return Right(property);
      } on ServerFailure catch (e) {
        return Left(e);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Property>> updateProperty(
    String id,
    Map<String, dynamic> data,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final property = await remoteDataSource.updateProperty(id, data);
        return Right(property);
      } on ServerFailure catch (e) {
        return Left(e);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProperty(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteProperty(id);
        return const Right(null);
      } on ServerFailure catch (e) {
        return Left(e);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<PropertyType>>> getPropertyTypes() async {
    if (await networkInfo.isConnected) {
      try {
        final types = await remoteDataSource.getPropertyTypes();
        return Right(types);
      } on ServerFailure catch (e) {
        return Left(e);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      // Could implement caching for types as well
      return Left(NetworkFailure('No internet connection'));
    }
  }
}
