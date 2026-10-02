import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/repositories/application_repository.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';

class FailingAppRepository implements ApplicationRepository {
  bool shouldFail = false;
  List<Application> apps = [];

  @override
  Future<List<Application>> getLandlordApplications(String landlordId) async {
    if (shouldFail) {
      throw Exception('NetworkException: Connection refused');
    }
    return apps;
  }

  @override
  Future<List<Application>> getTenantApplications(String tenantId) async {
    if (shouldFail) {
      throw Exception('NetworkException: Connection refused');
    }
    return apps;
  }

  @override
  Future<bool> updateApplicationStatus(String applicationId, String status) async => true;

  @override
  Future<Application> createApplication(Application application) async => application;

  @override
  Future<bool> hasApplicationForProperty(String tenantId, String propertyId) async => false;

  @override
  Future<bool> hasAcceptedApplicationsForProperty(String propertyId) async => false;

  @override
  Future<bool> deleteApplicationsForProperty(String propertyId) async => true;

  @override
  Future<bool> deleteApplication(String applicationId) async => true;
}

void main() {
  group('ApplicationProvider Resilience & Filter Preservation Tests [RF-22.3, RNF-09, QA 1.3, QA 1.14]', () {
    late FailingAppRepository mockRepo;
    late ApplicationProvider provider;

    final app1 = Application(
      id: 'app-1',
      arrendatarioId: 't-1',
      arrendadorId: 'l-1',
      propiedadId: 'p-1',
      estado: 'pendiente',
      createdAt: DateTime(2026, 9, 29, 10, 0),
      updatedAt: DateTime(2026, 9, 29, 10, 0),
    );

    setUp(() {
      mockRepo = FailingAppRepository();
      provider = ApplicationProvider(mockRepo);
    });

    test('QA 1.3: Preserves active filter across data fetches and refreshes', () async {
      mockRepo.apps = [app1];
      await provider.fetchLandlordApplications('l-1');

      provider.setFilter('Pendientes');
      expect(provider.currentFilter, 'Pendientes');

      // Subsequent refresh
      await provider.fetchLandlordApplications('l-1');
      expect(provider.currentFilter, 'Pendientes');
    });

    test('QA 1.14: Shows full screen error when initial load fails on empty list', () async {
      mockRepo.shouldFail = true;
      await provider.fetchLandlordApplications('l-1');

      expect(provider.applications, isEmpty);
      expect(provider.errorMessage, isNotNull);
      expect(provider.refreshErrorMessage, isNull);
    });

    test('QA 1.14, RNF-09: Pull-to-refresh network failure preserves existing applications in memory', () async {
      // 1. Initial successful load
      mockRepo.apps = [app1];
      await provider.fetchLandlordApplications('l-1');
      expect(provider.applications.length, 1);
      expect(provider.errorMessage, isNull);

      // 2. Simulated pull-to-refresh with network failure
      mockRepo.shouldFail = true;
      await provider.fetchLandlordApplications('l-1');

      // Existing list is retained!
      expect(provider.applications.length, 1);
      expect(provider.errorMessage, isNull);
      expect(provider.refreshErrorMessage, isNotNull);
      expect(provider.refreshErrorMessage, contains('No se pudo actualizar'));

      // 3. Clear refresh error
      provider.clearRefreshError();
      expect(provider.refreshErrorMessage, isNull);
    });

    test('Tenant flow: pull-to-refresh preserves existing applications on failure', () async {
      mockRepo.apps = [app1];
      await provider.fetchTenantApplications('t-1');
      expect(provider.applications.length, 1);

      mockRepo.shouldFail = true;
      await provider.fetchTenantApplications('t-1');

      expect(provider.applications.length, 1);
      expect(provider.errorMessage, isNull);
      expect(provider.refreshErrorMessage, isNotNull);
    });
  });
}
