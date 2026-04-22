import '../../../domain/entities/project.dart';
import '../../../domain/repositories/project_repository.dart';

class GetProjectsUseCase {
  final ProjectRepository repository;

  GetProjectsUseCase(this.repository);

  Future<List<Project>> call() async {
    return await repository.getProjects();
  }
}
