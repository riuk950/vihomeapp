import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';
import '../../domain/entities/property.dart';
import '../../domain/repositories/property_repository.dart';
import '../datasources/property_remote_datasource.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyRemoteDataSource remoteDataSource;

  PropertyRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Property>>> getProperties() async {
    try {
      final properties = await remoteDataSource.getProperties();
      return Right(properties);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Property>>> getPropertiesByLandlord(
    String landlordId,
  ) async {
    try {
      final properties = await remoteDataSource.getPropertiesByLandlord(
        landlordId,
      );
      return Right(properties);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Property>> createProperty(
    Map<String, dynamic> propertyData,
  ) async {
    try {
      final property = await remoteDataSource.createProperty(propertyData);
      return Right(property);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
