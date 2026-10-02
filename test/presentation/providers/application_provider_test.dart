import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vihomeapp/data/models/application_model.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/repositories/application_repository.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';
import '../../fixtures/fixtures.dart';

class MockApplicationRepo implements ApplicationRepository {
  List<Application> applications = [];

  @override
  Future<List<Application>> getLandlordApplications(String landlordId) async {
    return applications.where((a) => a.arrendadorId == landlordId).toList();
  }

  @override
  Future<List<Application>> getTenantApplications(String tenantId) async {
    return applications.where((a) => a.arrendatarioId == tenantId).toList();
  }

  @override
  Future<bool> updateApplicationStatus(String applicationId, String status) async {
    final index = applications.indexWhere((a) => a.id == applicationId);
    if (index != -1) {
      final old = applications[index];
      applications[index] = Application(
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
  Future<Application> createApplication(Application application) async {
    applications.add(application);
    return application;
  }

  @override
  Future<bool> hasApplicationForProperty(String tenantId, String propertyId) async =>
      applications.any((a) => a.arrendatarioId == tenantId && a.propiedadId == propertyId);

  @override
  Future<bool> hasAcceptedApplicationsForProperty(String propertyId) async =>
      applications.any((a) => a.propiedadId == propertyId && a.estado == 'Aprobada');

  @override
  Future<bool> deleteApplication(String applicationId) async => true;

  @override
  Future<bool> deleteApplicationsForProperty(String propertyId) async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockApplicationRepo mockRepo;
  late ApplicationProvider provider;

  final samplePending = ApplicationModel.fromJson(ApplicationFixtures.validPendingApplicationJson);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockRepo = MockApplicationRepo();
    mockRepo.applications = [samplePending];
    provider = ApplicationProvider(mockRepo);
  });

  group('ApplicationProvider Comprehensive Tests [RF-04, RF-06]', () {
    test('updateStatus should update status reactively [RF-06.2, RF-06.3]', () async {
      final success = await provider.updateStatus(samplePending.id, 'Aprobada');

      expect(success, isTrue);
    });

    test('hasApplicationForProperty should detect existing tenant application [CL-04]', () async {
      final exists = await provider.hasApplicationForProperty(
        samplePending.arrendatarioId,
        samplePending.propiedadId,
      );

      expect(exists, isTrue);
    });

    test('hasAcceptedApplicationsForProperty should detect accepted state [RF-06.2]', () async {
      final hasAccepted = await provider.hasAcceptedApplicationsForProperty(samplePending.propiedadId);
      expect(hasAccepted, isFalse);

      mockRepo.applications = [
        ApplicationModel.fromJson(ApplicationFixtures.validApprovedApplicationJson),
      ];
      final nowAccepted = await provider.hasAcceptedApplicationsForProperty(samplePending.propiedadId);
      expect(nowAccepted, isTrue);
    });

    test('deleteApplicationsForProperty should call repository to clean up [RF-05.4]', () async {
      final result = await provider.deleteApplicationsForProperty(samplePending.propiedadId);
      expect(result, isTrue);
    });
  });
}
