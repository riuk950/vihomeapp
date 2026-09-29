import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/repositories/application_repository.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';

class MockAppRepository implements ApplicationRepository {
  List<Application> landlordApps = [];
  List<Application> tenantApps = [];

  @override
  Future<List<Application>> getLandlordApplications(String landlordId) async => landlordApps;

  @override
  Future<List<Application>> getTenantApplications(String tenantId) async => tenantApps;

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
  group('ApplicationProvider Filter and Counting Tests [RF-21.1, RF-21.2, RF-21.3, QA 1.3, QA 1.17]', () {
    late MockAppRepository mockRepo;
    late ApplicationProvider provider;

    final app1 = Application(
      id: 'app-1',
      arrendatarioId: 't-1',
      arrendadorId: 'l-1',
      propiedadId: 'p-1',
      estado: 'pendiente',
      createdAt: DateTime(2026, 9, 25, 10, 0),
      updatedAt: DateTime(2026, 9, 25, 10, 0),
    );

    final app2 = Application(
      id: 'app-2',
      arrendatarioId: 't-2',
      arrendadorId: 'l-1',
      propiedadId: 'p-2',
      estado: 'aceptada',
      createdAt: DateTime(2026, 9, 27, 12, 0),
      updatedAt: DateTime(2026, 9, 27, 12, 0),
    );

    final app3 = Application(
      id: 'app-3',
      arrendatarioId: 't-3',
      arrendadorId: 'l-1',
      propiedadId: 'p-1',
      estado: 'rechazada',
      createdAt: DateTime(2026, 9, 26, 9, 0),
      updatedAt: DateTime(2026, 9, 26, 9, 0),
    );

    final app4 = Application(
      id: 'app-4',
      arrendatarioId: 't-4',
      arrendadorId: 'l-1',
      propiedadId: 'p-3',
      estado: 'pendiente',
      createdAt: DateTime(2026, 9, 29, 8, 0),
      updatedAt: DateTime(2026, 9, 29, 8, 0),
    );

    setUp(() {
      mockRepo = MockAppRepository();
      provider = ApplicationProvider(mockRepo);
    });

    test('RF-21.1, QA 1.17: Calculates dynamic counts for all filter categories correctly', () async {
      mockRepo.landlordApps = [app1, app2, app3, app4];
      await provider.fetchLandlordApplications('l-1');

      expect(provider.totalCount, 4);
      expect(provider.pendingCount, 2);
      expect(provider.acceptedCount, 1);
      expect(provider.rejectedCount, 1);
    });

    test('RF-21.2: Filters applications reactively by status and maintains chronological descending order', () async {
      mockRepo.landlordApps = [app1, app2, app3, app4];
      await provider.fetchLandlordApplications('l-1');

      // Default filter is 'Todas'
      expect(provider.currentFilter, 'Todas');
      expect(provider.filteredApplications.length, 4);
      // Chronological descending: app4 (sep 29), app2 (sep 27), app3 (sep 26), app1 (sep 25)
      expect(provider.filteredApplications.first.id, 'app-4');
      expect(provider.filteredApplications.last.id, 'app-1');

      // Filter by 'Pendientes'
      provider.setFilter('Pendientes');
      expect(provider.filteredApplications.length, 2);
      expect(provider.filteredApplications.map((a) => a.id), containsAllInOrder(['app-4', 'app-1']));

      // Filter by 'Aceptadas'
      provider.setFilter('Aceptadas');
      expect(provider.filteredApplications.length, 1);
      expect(provider.filteredApplications.first.id, 'app-2');

      // Filter by 'Rechazadas'
      provider.setFilter('Rechazadas');
      expect(provider.filteredApplications.length, 1);
      expect(provider.filteredApplications.first.id, 'app-3');
    });

    test('Backwards compatibility: supports filter "Revisadas"', () async {
      mockRepo.landlordApps = [app1, app2, app3, app4];
      await provider.fetchLandlordApplications('l-1');

      provider.setFilter('Revisadas');
      expect(provider.filteredApplications.length, 2);
      expect(provider.filteredApplications.map((a) => a.id), containsAllInOrder(['app-2', 'app-3']));
    });
  });
}
