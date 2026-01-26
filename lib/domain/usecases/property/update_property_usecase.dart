import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/domain/entities/property.dart';
import 'package:vihomeapp/domain/repositories/property_repository.dart';

class UpdatePropertyUseCase {
  final PropertyRepository repository;

  UpdatePropertyUseCase(this.repository);

  Future<Either<Failure, Property>> call(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await repository.updateProperty(id, data);
  }
}
