import '../../entities/constructora.dart';
import '../../repositories/project_repository.dart';

class GetConstructoraUseCase {
  final ProjectRepository repository;

  GetConstructoraUseCase(this.repository);

  Future<Constructora> call(String id) async {
    return await repository.getConstructora(id);
  }
}
