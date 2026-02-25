import '../entities/project.dart';
import '../entities/constructora.dart';

abstract class ProjectRepository {
  Future<List<Project>> getProjects();
  Future<Constructora> getConstructora(String id);
}
