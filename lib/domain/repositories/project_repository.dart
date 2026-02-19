import '../entities/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> getProjects();
}
