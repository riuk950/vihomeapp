import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/repositories/application_repository.dart';
import 'package:vihomeapp/presentation/pages/tenant/widgets/contextual_form_widgets.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';

class DummyApplicationRepo implements ApplicationRepository {
  @override
  Future<List<Application>> getLandlordApplications(String landlordId) async => [];
  @override
  Future<List<Application>> getTenantApplications(String tenantId) async => [];
  @override
  Future<bool> updateApplicationStatus(String applicationId, String status) async => true;
  @override
  Future<Application> createApplication(Application application) async => application;
  @override
  Future<bool> hasApplicationForProperty(String tenantId, String propertyId) async => false;
  @override
  Future<bool> hasAcceptedApplicationsForProperty(String propertyId) async => false;
  @override
  Future<bool> deleteApplication(String applicationId) async => true;
  @override
  Future<bool> deleteApplicationsForProperty(String propertyId) async => true;
}

Widget createTestableWidget(Widget child, ApplicationProvider provider) {
  return ChangeNotifierProvider<ApplicationProvider>.value(
    value: provider,
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ApplicationProvider provider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    provider = ApplicationProvider(DummyApplicationRepo());
  });

  tearDown(() {
    provider.dispose();
  });

  group('FormResidencialWidget [RF-14, RNF-08, RNF-10]', () {
    testWidgets('renders occupants, description and toggles pet details reactively', (tester) async {
      provider.initContextualForm('Casa');

      await tester.pumpWidget(createTestableWidget(const FormResidencialWidget(), provider));
      await tester.pumpAndSettle();

      expect(find.text('Número de ocupantes'), findsOneWidget);
      expect(find.text('Composición del núcleo familiar'), findsOneWidget);
      expect(find.text('¿Tienen mascotas?'), findsOneWidget);
      expect(find.text('Detalle de mascotas (tipo y cantidad)'), findsNothing);

      // Toggle hasPets switch to true
      final petSwitch = find.byType(Switch);
      expect(petSwitch, findsOneWidget);
      await tester.tap(petSwitch);
      await tester.pumpAndSettle();

      // Pet details should appear reactively [RNF-08]
      expect(find.text('Detalle de mascotas (tipo y cantidad)'), findsOneWidget);

      // Enter pet details
      await tester.enterText(find.byKey(const Key('petDetailsField')), 'Un gato persa');
      await tester.pumpAndSettle();
      expect(provider.petDetailsController.text, equals('Un gato persa'));

      // Toggle switch off -> details disappear from UI but remain in controller [RNF-09]
      await tester.tap(petSwitch);
      await tester.pumpAndSettle();
      expect(find.text('Detalle de mascotas (tipo y cantidad)'), findsNothing);
      expect(provider.petDetailsController.text, equals('Un gato persa'));
    });
  });

  group('FormIndividualWidget [RF-15, RNF-08, RNF-10]', () {
    testWidgets('renders occupation, workplace and toggles guardian fields reactively for minors', (tester) async {
      provider.initContextualForm('Habitación');

      await tester.pumpWidget(createTestableWidget(const FormIndividualWidget(), provider));
      await tester.pumpAndSettle();

      expect(find.text('Ocupación principal'), findsOneWidget);
      expect(find.text('Lugar de estudio o empresa'), findsOneWidget);
      expect(find.text('¿El solicitante es menor de edad?'), findsOneWidget);

      // Guardian fields should be hidden initially
      expect(find.text('Nombre completo del acudiente'), findsNothing);
      expect(find.text('Teléfono de contacto del acudiente'), findsNothing);

      // Toggle minor switch to true
      final minorSwitch = find.byType(Switch);
      await tester.tap(minorSwitch);
      await tester.pumpAndSettle();

      // Guardian fields must appear reactively [RNF-08, RF-15.3]
      expect(find.text('Nombre completo del acudiente'), findsOneWidget);
      expect(find.text('Teléfono de contacto del acudiente'), findsOneWidget);
      expect(find.text('Parentesco o relación legal'), findsOneWidget);

      // Enter guardian info
      await tester.enterText(find.byKey(const Key('guardianNameField')), 'Roberto Gómez');
      await tester.enterText(find.byKey(const Key('guardianPhoneField')), '3112345678');
      await tester.pumpAndSettle();

      expect(provider.guardianNameController.text, equals('Roberto Gómez'));
      expect(provider.guardianPhoneController.text, equals('3112345678'));
    });
  });

  group('FormComercialWidget [RF-16, RNF-10]', () {
    testWidgets('renders business name, NIT and economic activity fields', (tester) async {
      provider.initContextualForm('Local');

      await tester.pumpWidget(createTestableWidget(const FormComercialWidget(), provider));
      await tester.pumpAndSettle();

      expect(find.text('Nombre comercial o razón social'), findsOneWidget);
      expect(find.text('NIT o documento tributario'), findsOneWidget);
      expect(find.text('Actividad económica y uso previsto'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('businessNameField')), 'Boutique Floral');
      await tester.enterText(find.byKey(const Key('nitField')), '900.876.543-2');
      await tester.enterText(find.byKey(const Key('economicActivityField')), 'Venta de flores y arreglos ornamentales.');
      await tester.pumpAndSettle();

      expect(provider.businessNameController.text, equals('Boutique Floral'));
      expect(provider.nitController.text, equals('900.876.543-2'));
      expect(provider.economicActivityController.text, equals('Venta de flores y arreglos ornamentales.'));
    });
  });
}
