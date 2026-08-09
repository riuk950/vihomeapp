import 'package:vihomeapp/data/datasources/application_datasource.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/repositories/application_repository.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  final ApplicationDatasource datasource;

  ApplicationRepositoryImpl(this.datasource);

  @override
  Future<List<Application>> getLandlordApplications(String landlordId) async {
    return await datasource.getLandlordApplications(landlordId);
  }

  @override
  Future<List<Application>> getTenantApplications(String tenantId) async {
    return await datasource.getTenantApplications(tenantId);
  }

  @override
  Future<bool> updateApplicationStatus(
    String applicationId,
    String status,
  ) async {
    return await datasource.updateApplicationStatus(applicationId, status);
  }

  @override
  Future<Application> createApplication(Application application) async {
    return await datasource.createApplication(application as dynamic);
  }

  @override
  Future<bool> hasApplicationForProperty(
    String tenantId,
    String propertyId,
  ) async {
    return await datasource.hasApplicationForProperty(tenantId, propertyId);
  }

  @override
  Future<bool> hasAcceptedApplicationsForProperty(String propertyId) async {
    return await datasource.hasAcceptedApplicationsForProperty(propertyId);
  }

  @override
  Future<bool> deleteApplication(String applicationId) async {
    return await datasource.deleteApplication(applicationId);
  }

  @override
  Future<bool> deleteApplicationsForProperty(String propertyId) async {
    return await datasource.deleteApplicationsForProperty(propertyId);
  }
}
