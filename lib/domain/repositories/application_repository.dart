import 'package:vihomeapp/domain/entities/application.dart';

abstract class ApplicationRepository {
  Future<List<Application>> getLandlordApplications(String landlordId);
  Future<List<Application>> getTenantApplications(String tenantId);
  Future<bool> updateApplicationStatus(String applicationId, String status);
  Future<Application> createApplication(Application application);
  Future<bool> hasApplicationForProperty(String tenantId, String propertyId);
  Future<bool> hasAcceptedApplicationsForProperty(String propertyId);
  Future<bool> deleteApplication(String applicationId);
  Future<bool> deleteApplicationsForProperty(String propertyId);
}
