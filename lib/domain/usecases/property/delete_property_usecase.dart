import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/domain/repositories/property_repository.dart';

class DeletePropertyUseCase {
  final PropertyRepository repository;

  DeletePropertyUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteProperty(id);
  }
}
