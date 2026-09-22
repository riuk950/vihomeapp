import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/data/models/application_model.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/repositories/application_repository.dart';
import '../../../fixtures/fixtures.dart';

class LandlordApplicationRepo implements ApplicationRepository {
  final List<Application> _applications = [];

  LandlordApplicationRepo(List<Application> initial) {
    _applications.addAll(initial);
  }

  @override
  Future<List<Application>> getLandlordApplications(String landlordId) async {
    return _applications.where((a) => a.arrendadorId == landlordId).toList();
  }

  @override
  Future<List<Application>> getTenantApplications(String tenantId) async {
    return _applications.where((a) => a.arrendatarioId == tenantId).toList();
  }

  @override
  Future<bool> updateApplicationStatus(String applicationId, String status) async {
    final index = _applications.indexWhere((a) => a.id == applicationId);
    if (index != -1) {
      final old = _applications[index];
      _applications[index] = Application(
        id: old.id,
        arrendatarioId: old.arrendatarioId,
        arrendadorId: old.arrendadorId,
        propiedadId: old.propiedadId,
        estado: status,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
        ingresosMensuales: old.ingresosMensuales,
        documentoUrl: old.documentoUrl,
      );
      return true;
    }
    return false;
  }

  @override
  Future<Application> createApplication(Application application) async => application;

  @override
  Future<bool> hasApplicationForProperty(String tenantId, String propertyId) async => false;

  @override
  Future<bool> hasAcceptedApplicationsForProperty(String propertyId) async =>
      _applications.any((a) => a.propiedadId == propertyId && a.estado == 'Aprobada');

  @override
  Future<bool> deleteApplication(String applicationId) async => true;

  @override
  Future<bool> deleteApplicationsForProperty(String propertyId) async => true;
}

void main() {
  late LandlordApplicationRepo repo;
  final appPending = ApplicationModel.fromJson(ApplicationFixtures.validPendingApplicationJson);

  setUp(() {
    repo = LandlordApplicationRepo([appPending]);
  });

  group('Landlord Manage Applications UseCase Tests [RF-06]', () {
    test('should retrieve applications received by landlord [RF-06.1]', () async {
      final list = await repo.getLandlordApplications(appPending.arrendadorId);

      expect(list, hasLength(1));
      expect(list.first.id, appPending.id);
      expect(list.first.ingresosMensuales, '8500000');
    });

    test('should update application status to Aprobada [RF-06.2, RF-06.3]', () async {
      final success = await repo.updateApplicationStatus(appPending.id, 'Aprobada');
      expect(success, isTrue);

      final updatedList = await repo.getLandlordApplications(appPending.arrendadorId);
      expect(updatedList.first.estado, 'Aprobada');
      expect(await repo.hasAcceptedApplicationsForProperty(appPending.propiedadId), isTrue);
    });

    test('should update application status to Rechazada [RF-06.2, RF-06.3]', () async {
      final success = await repo.updateApplicationStatus(appPending.id, 'Rechazada');
      expect(success, isTrue);

      final updatedList = await repo.getLandlordApplications(appPending.arrendadorId);
      expect(updatedList.first.estado, 'Rechazada');
    });
  });
}
