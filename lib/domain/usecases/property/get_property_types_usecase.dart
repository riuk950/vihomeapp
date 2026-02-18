import '../../../core/errors/failures.dart';
import '../../../core/utils/either.dart';
import '../../repositories/property_repository.dart';
import '../../entities/property_type.dart';

class GetPropertyTypesUseCase {
  final PropertyRepository repository;

  GetPropertyTypesUseCase(this.repository);

  Future<Either<Failure, List<PropertyType>>> call() async {
    return await repository.getPropertyTypes();
  }
}
