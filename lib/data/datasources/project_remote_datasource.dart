import '../../core/errors/failures.dart';
import '../models/project_model.dart';
import '../../infrastructure/services/supabase_service.dart';

abstract class ProjectRemoteDataSource {
  Future<List<ProjectModel>> getProjects();
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final SupabaseService supabaseService;

  ProjectRemoteDataSourceImpl(this.supabaseService);

  @override
  Future<List<ProjectModel>> getProjects() async {
    try {
      final response =
          await supabaseService.client.from('proyectos').select('*');
      return (response as List).map((p) => ProjectModel.fromJson(p)).toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
