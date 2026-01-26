import '../../../core/errors/failures.dart';
import '../../../core/utils/either.dart';
import '../../entities/property.dart';
import '../../repositories/property_repository.dart';

class GetPropertiesUseCase {
  final PropertyRepository repository;

  GetPropertiesUseCase(this.repository);

  Future<Either<Failure, List<Property>>> call() {
    return repository.getProperties();
  }
}
