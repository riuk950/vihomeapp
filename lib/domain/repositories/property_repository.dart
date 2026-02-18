import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';
import '../entities/property.dart';
import '../../domain/entities/property_type.dart';

abstract class PropertyRepository {
  Future<Either<Failure, List<Property>>> getProperties();
  Future<Either<Failure, List<Property>>> getPropertiesByLandlord(
    String landlordId,
  );
  Future<Either<Failure, Property>> createProperty(
    Map<String, dynamic> propertyData,
  );
  Future<Either<Failure, Property>> updateProperty(
      String id, Map<String, dynamic> data);
  Future<Either<Failure, List<PropertyType>>> getPropertyTypes();
}
