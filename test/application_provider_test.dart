import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/repositories/application_repository.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';

class FakeApplicationRepository implements ApplicationRepository {
  bool acceptedCheckCalled = false;
  bool deleteApplicationsCalled = false;
  bool shouldReturnAccepted = false;
  bool shouldDelete = true;

  @override
  Future<List<Application>> getLandlordApplications(String landlordId) async {
    return [];
  }

  @override
  Future<List<Application>> getTenantApplications(String tenantId) async {
    return [];
  }

  @override
  Future<bool> updateApplicationStatus(
      String applicationId, String status) async {
    return true;
  }

  @override
  Future<Application> createApplication(Application application) async {
    return application;
  }

  @override
  Future<bool> hasApplicationForProperty(
      String tenantId, String propertyId) async {
    return false;
  }

  @override
  Future<bool> hasAcceptedApplicationsForProperty(String propertyId) async {
    acceptedCheckCalled = true;
    return shouldReturnAccepted;
  }

  @override
  Future<bool> deleteApplicationsForProperty(String propertyId) async {
    deleteApplicationsCalled = true;
    return shouldDelete;
  }
}

void main() {
  group('ApplicationProvider property lifecycle rules', () {
    test('detecta si la propiedad tiene solicitudes aceptadas', () async {
      final repo = FakeApplicationRepository();
      repo.shouldReturnAccepted = true;
      final provider = ApplicationProvider(repo);

      final result =
          await provider.hasAcceptedApplicationsForProperty('prop_123');

      expect(result, isTrue);
      expect(repo.acceptedCheckCalled, isTrue);
    });

    test('elimina todas las solicitudes asociadas al reactivar la propiedad',
        () async {
      final repo = FakeApplicationRepository();
      repo.shouldDelete = true;
      final provider = ApplicationProvider(repo);

      final result = await provider.deleteApplicationsForProperty('prop_123');

      expect(result, isTrue);
      expect(repo.deleteApplicationsCalled, isTrue);
    });
  });
}
