import '../../../core/errors/failures.dart';
import '../../../core/utils/either.dart';
import '../../entities/property.dart';
import '../../repositories/property_repository.dart';

class CreatePropertyUseCase {
  final PropertyRepository repository;

  CreatePropertyUseCase(this.repository);

  Future<Either<Failure, Property>> call(Map<String, dynamic> propertyData) {
    return repository.createProperty(propertyData);
  }
}
