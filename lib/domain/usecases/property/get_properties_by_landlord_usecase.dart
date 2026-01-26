import '../../../core/errors/failures.dart';
import '../../../core/utils/either.dart';
import '../../entities/property.dart';
import '../../repositories/property_repository.dart';

class GetPropertiesByLandlordUseCase {
  final PropertyRepository repository;

  GetPropertiesByLandlordUseCase(this.repository);

  Future<Either<Failure, List<Property>>> call(String landlordId) {
    return repository.getPropertiesByLandlord(landlordId);
  }
}
