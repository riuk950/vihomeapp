import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/repositories/application_repository.dart';

class CreateApplicationUseCase {
  final ApplicationRepository repository;

  CreateApplicationUseCase(this.repository);

  Future<Application> call(Application application) async {
    return await repository.createApplication(application);
  }
}
