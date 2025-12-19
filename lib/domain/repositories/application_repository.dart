import 'package:vihomeapp/domain/entities/application.dart';

abstract class ApplicationRepository {
  Future<List<Application>> getLandlordApplications(String landlordId);
  Future<List<Application>> getTenantApplications(String tenantId);
  Future<bool> updateApplicationStatus(String applicationId, String status);
}
