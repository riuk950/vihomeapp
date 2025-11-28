import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';
import '../entities/property.dart';

abstract class PropertyRepository {
  Future<Either<Failure, List<Property>>> getProperties();
  Future<Either<Failure, List<Property>>> getPropertiesByLandlord(
    String landlordId,
  );
}
