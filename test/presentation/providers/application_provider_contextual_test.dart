import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vihomeapp/core/utils/property_category_resolver.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/entities/application_context_data.dart';
import 'package:vihomeapp/domain/repositories/application_repository.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';

class FakeContextualApplicationRepo implements ApplicationRepository {
  List<Application> applications = [];
  bool hasAppResult = false;

  @override
  Future<List<Application>> getLandlordApplications(String landlordId) async => [];

  @override
  Future<List<Application>> getTenantApplications(String tenantId) async => [];

  @override
  Future<bool> updateApplicationStatus(String applicationId, String status) async => true;

  @override
  Future<Application> createApplication(Application application) async {
    applications.add(application);
    return application;
  }

  @override
  Future<bool> hasApplicationForProperty(String tenantId, String propertyId) async {
    return hasAppResult;
  }

  @override
  Future<bool> hasAcceptedApplicationsForProperty(String propertyId) async => false;

  @override
  Future<bool> deleteApplication(String applicationId) async => true;

  @override
  Future<bool> deleteApplicationsForProperty(String propertyId) async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeContextualApplicationRepo fakeRepo;
  late ApplicationProvider provider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    fakeRepo = FakeContextualApplicationRepo();
    provider = ApplicationProvider(fakeRepo);
  });

  tearDown(() {
    provider.dispose();
  });

  group('ApplicationProvider - Contextual Form Management [RF-13, RF-14, RF-15, RF-16, RNF-08, RNF-09]', () {
    test('initContextualForm should set category properly using resolver [RF-13.1, RF-13.2]', () {
      provider.initContextualForm('Apartamento');
      expect(provider.currentCategory, equals(PropertyCategory.residential));

      provider.initContextualForm('Habitación');
      expect(provider.currentCategory, equals(PropertyCategory.individual));

      provider.initContextualForm('Local');
      expect(provider.currentCategory, equals(PropertyCategory.commercial));

      provider.initContextualForm(null);
      expect(provider.currentCategory, equals(PropertyCategory.residential));
    });

    test('Residential contextual validation and data preservation in memory [RF-14, RNF-09, CL-10, CL-12]', () {
      provider.initContextualForm('Casa');
      expect(provider.isContextualFormValid, isFalse);

      // Fill occupants and family description
      provider.occupantsController.text = '3';
      provider.familyDescriptionController.text = 'Familia conformada por padres e hijo.';
      provider.notifyValidationChange();
      expect(provider.isContextualFormValid, isTrue);

      // Toggle pets without details -> becomes invalid [CL-12]
      provider.setHasPets(true);
      expect(provider.isContextualFormValid, isFalse);

      // Add pet details -> becomes valid
      provider.petDetailsController.text = 'Un perro labrador de 2 años';
      provider.notifyValidationChange();
      expect(provider.isContextualFormValid, isTrue);

      // Toggle pets off -> pet details MUST be preserved in memory [RNF-09]
      provider.setHasPets(false);
      expect(provider.petDetailsController.text, equals('Un perro labrador de 2 años'));
      expect(provider.isContextualFormValid, isTrue);

      // buildContextData should not include pets if hasPets is false
      final data = provider.buildContextData();
      expect(data, isA<ResidentialContextData>());
      final residential = data as ResidentialContextData;
      expect(residential.tieneMascotas, isFalse);
      expect(residential.detalleMascotas, isNull);

      // Toggle back to true -> pet details are intact and valid
      provider.setHasPets(true);
      final dataWithPets = provider.buildContextData() as ResidentialContextData;
      expect(dataWithPets.tieneMascotas, isTrue);
      expect(dataWithPets.detalleMascotas, equals('Un perro labrador de 2 años'));
    });

    test('Individual contextual validation with minor and guardian info [RF-15, RNF-09, CL-11]', () {
      provider.initContextualForm('Habitación');
      expect(provider.isContextualFormValid, isFalse);

      provider.setSelectedOccupation('Estudiante');
      provider.workplaceOrSchoolController.text = 'Universidad Nacional';
      provider.notifyValidationChange();
      expect(provider.isContextualFormValid, isTrue);

      // Toggle isMinor -> requires guardian info [CL-11]
      provider.setIsMinor(true);
      expect(provider.isContextualFormValid, isFalse);

      provider.guardianNameController.text = 'Carlos Eduardo Gómez';
      provider.guardianPhoneController.text = '3109876543';
      provider.setGuardianRelationship('Padre/Madre');
      provider.notifyValidationChange();
      expect(provider.isContextualFormValid, isTrue);

      // Toggle isMinor off -> data preserved in controllers [RNF-09]
      provider.setIsMinor(false);
      expect(provider.guardianNameController.text, equals('Carlos Eduardo Gómez'));
      expect(provider.guardianPhoneController.text, equals('3109876543'));
      expect(provider.isContextualFormValid, isTrue);

      final dataAdult = provider.buildContextData() as IndividualContextData;
      expect(dataAdult.esMenorDeEdad, isFalse);
      expect(dataAdult.acudiente, isNull);

      // Toggle isMinor back on -> guardian restored
      provider.setIsMinor(true);
      final dataMinor = provider.buildContextData() as IndividualContextData;
      expect(dataMinor.esMenorDeEdad, isTrue);
      expect(dataMinor.acudiente, isNotNull);
      expect(dataMinor.acudiente!.nombreCompleto, equals('Carlos Eduardo Gómez'));
      expect(dataMinor.acudiente!.telefono, equals('3109876543'));
    });

    test('Commercial contextual validation [RF-16]', () {
      provider.initContextualForm('Local');
      expect(provider.isContextualFormValid, isFalse);

      provider.businessNameController.text = 'Panadería Artesanal SAS';
      provider.nitController.text = '901.345.678-1';
      provider.economicActivityController.text = 'Venta de productos de panadería y pastelería.';
      provider.notifyValidationChange();
      expect(provider.isContextualFormValid, isTrue);

      final data = provider.buildContextData() as CommercialContextData;
      expect(data.razonSocial, equals('Panadería Artesanal SAS'));
      expect(data.nit, equals('901.345.678-1'));
      expect(data.actividadEconomica, equals('Venta de productos de panadería y pastelería.'));
    });

    test('submitContextualApplication should prevent duplicates when active app exists [CL-10, CL-13]', () async {
      provider.initContextualForm('Casa');
      provider.occupantsController.text = '2';
      provider.familyDescriptionController.text = 'Pareja de profesionales.';
      provider.notifyValidationChange();

      // Simulate that user already has an active application
      fakeRepo.hasAppResult = true;

      final success = await provider.submitContextualApplication(
        tenantId: 'usr-1',
        landlordId: 'usr-2',
        propertyId: 'prop-1',
        ingresosMensuales: '\$ 4.000.000',
        documentoUrl: 'https://storage/doc.pdf',
      );

      expect(success, isFalse);
      expect(provider.errorMessage, contains('Ya tienes una solicitud'));
      expect(fakeRepo.applications, isEmpty);
    });

    test('submitContextualApplication should successfully create application with contextual data', () async {
      provider.initContextualForm('Local');
      provider.businessNameController.text = 'Tienda Deportiva';
      provider.nitController.text = '800.123.456-7';
      provider.economicActivityController.text = 'Venta de calzado deportivo y accesorios.';
      provider.notifyValidationChange();

      fakeRepo.hasAppResult = false;

      final success = await provider.submitContextualApplication(
        tenantId: 'usr-1',
        landlordId: 'usr-2',
        propertyId: 'prop-1',
        ingresosMensuales: '\$ 8.000.000',
        documentoUrl: 'https://storage/doc.pdf',
      );

      expect(success, isTrue);
      expect(fakeRepo.applications.length, equals(1));
      final created = fakeRepo.applications.first;
      expect(created.datosContextuales, isA<CommercialContextData>());
      final commercial = created.datosContextuales as CommercialContextData;
      expect(commercial.razonSocial, equals('Tienda Deportiva'));
    });
  });
}
