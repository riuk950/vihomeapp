import '../../core/errors/failures.dart';
import '../models/project_model.dart';
import '../models/constructora_model.dart';
import '../../infrastructure/services/supabase_service.dart';

abstract class ProjectRemoteDataSource {
  Future<List<ProjectModel>> getProjects();
  Future<ConstructoraModel> getConstructora(String id);
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

  @override
  Future<ConstructoraModel> getConstructora(String id) async {
    try {
      final response = await supabaseService.client
          .from('contructora')
          .select('*')
          .eq('id', id)
          .single();
      return ConstructoraModel.fromJson(response);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
