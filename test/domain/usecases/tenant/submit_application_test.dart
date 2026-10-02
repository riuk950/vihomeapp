import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/data/models/application_model.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/repositories/application_repository.dart';
import 'package:vihomeapp/domain/usecases/tenant/create_application_usecase.dart';
import '../../../fixtures/fixtures.dart';

class MockApplicationRepository implements ApplicationRepository {
  final List<Application> _applications = [];

  @override
  Future<Application> createApplication(Application application) async {
    // Validación de ingresos obligatorios [RF-04.2]
    if (application.ingresosMensuales == null || application.ingresosMensuales!.isEmpty) {
      throw Exception('El ingreso mensual es obligatorio.');
    }

    // Validación de comprobante obligatorio [RF-04.2]
    if (application.documentoUrl == null || application.documentoUrl!.isEmpty) {
      throw Exception('Debe adjuntar al menos un comprobante de ingresos.');
    }

    // Prevención de duplicados para la misma propiedad [CL-04]
    final exists = await hasApplicationForProperty(application.arrendatarioId, application.propiedadId);
    if (exists) {
      throw Exception('Ya tienes una postulación activa para este inmueble.');
    }

    _applications.add(application);
    return application;
  }

  @override
  Future<bool> hasApplicationForProperty(String tenantId, String propertyId) async {
    return _applications.any((a) => a.arrendatarioId == tenantId && a.propiedadId == propertyId);
  }

  @override
  Future<List<Application>> getLandlordApplications(String landlordId) async =>
      _applications.where((a) => a.arrendadorId == landlordId).toList();

  @override
  Future<List<Application>> getTenantApplications(String tenantId) async =>
      _applications.where((a) => a.arrendatarioId == tenantId).toList();

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
  Future<bool> hasAcceptedApplicationsForProperty(String propertyId) async =>
      _applications.any((a) => a.propiedadId == propertyId && a.estado == 'Aprobada');

  @override
  Future<bool> deleteApplication(String applicationId) async => true;

  @override
  Future<bool> deleteApplicationsForProperty(String propertyId) async => true;
}

void main() {
  late MockApplicationRepository mockRepo;
  late CreateApplicationUseCase createApplicationUseCase;

  setUp(() {
    mockRepo = MockApplicationRepository();
    createApplicationUseCase = CreateApplicationUseCase(mockRepo);
  });

  group('CreateApplicationUseCase Tests [RF-04, CL-04]', () {
    test('should successfully submit application with valid income and proof document [RF-04.1, RF-04.3]', () async {
      final app = ApplicationModel.fromJson(ApplicationFixtures.validPendingApplicationJson);
      final created = await createApplicationUseCase(app);

      expect(created.id, app.id);
      expect(created.ingresosMensuales, '8500000');
      expect(created.documentoUrl, isNotEmpty);
      expect(await mockRepo.hasApplicationForProperty(app.arrendatarioId, app.propiedadId), isTrue);
    });

    test('should fail when income is missing [RF-04.2]', () async {
      final invalidApp = Application(
        id: 'app_inv_1',
        arrendatarioId: 'usr_tenant',
        arrendadorId: 'usr_landlord',
        propiedadId: 'prop_1',
        estado: 'Pendiente',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ingresosMensuales: null,
        documentoUrl: 'https://storage/extracto.pdf',
      );

      expect(
        () => createApplicationUseCase(invalidApp),
        throwsA(predicate((e) => e.toString().contains('ingreso mensual es obligatorio'))),
      );
    });

    test('should fail when proof document is missing [RF-04.2]', () async {
      final invalidApp = Application(
        id: 'app_inv_2',
        arrendatarioId: 'usr_tenant',
        arrendadorId: 'usr_landlord',
        propiedadId: 'prop_1',
        estado: 'Pendiente',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ingresosMensuales: '5000000',
        documentoUrl: null,
      );

      expect(
        () => createApplicationUseCase(invalidApp),
        throwsA(predicate((e) => e.toString().contains('comprobante de ingresos'))),
      );
    });

    test('should prevent submitting duplicate application for same property [CL-04]', () async {
      final app = ApplicationModel.fromJson(ApplicationFixtures.validPendingApplicationJson);
      await createApplicationUseCase(app);

      // Intento de reenvío duplicado
      expect(
        () => createApplicationUseCase(app),
        throwsA(predicate((e) => e.toString().contains('Ya tienes una postulación activa'))),
      );
    });
  });
}
