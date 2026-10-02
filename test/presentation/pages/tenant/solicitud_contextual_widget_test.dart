import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/data/models/user_model.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/entities/application_context_data.dart';
import 'package:vihomeapp/domain/entities/user.dart';
import 'package:vihomeapp/domain/repositories/application_repository.dart';
import 'package:vihomeapp/domain/repositories/auth_repository.dart';
import 'package:vihomeapp/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/reset_password_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_in_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_in_with_google_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_out_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_up_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/update_user_role_usecase.dart';
import 'package:vihomeapp/presentation/pages/tenant/solicitud_de_arriendo_page.dart';
import 'package:vihomeapp/presentation/pages/tenant/widgets/contextual_form_widgets.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import '../../../fixtures/fixtures.dart';

class MockAuthRepo implements AuthRepository {
  User? currentUser;
  @override
  Future<Either<Failure, User?>> getCurrentUser() async => Right(currentUser);
  @override
  Future<Either<Failure, User>> signInWithEmail({required String email, required String password}) async => Right(currentUser!);
  @override
  Future<Either<Failure, User>> signUp({required String email, required String password, Map<String, dynamic>? metadata}) async => Right(currentUser!);
  @override
  Future<Either<Failure, void>> signOut() async => const Right(null);
  @override
  Future<Either<Failure, User>> signInWithGoogle() async => const Left(AuthFailure('err'));
  @override
  Future<Either<Failure, void>> resetPassword(String email) async => const Right(null);
  @override
  Future<Either<Failure, void>> updatePassword(String newPassword) async => const Right(null);
  @override
  Future<Either<Failure, void>> updateUserRole(String role) async => const Right(null);
  @override
  Stream<Either<Failure, User?>> authStateChanges() => Stream.value(Right(currentUser));
}

class MockApplicationRepo implements ApplicationRepository {
  bool shouldFailCreate = false;
  bool propertyHasActiveApplication = false;
  Application? lastCreatedApplication;

  @override
  Future<List<Application>> getLandlordApplications(String landlordId) async => [];
  @override
  Future<List<Application>> getTenantApplications(String tenantId) async => [];
  @override
  Future<bool> updateApplicationStatus(String applicationId, String status) async => true;
  @override
  Future<Application> createApplication(Application application) async {
    if (shouldFailCreate) {
      throw Exception('Fallo de conexión simulado con el servidor');
    }
    lastCreatedApplication = application;
    return application;
  }
  @override
  Future<bool> hasApplicationForProperty(String tenantId, String propertyId) async =>
      propertyHasActiveApplication;
  @override
  Future<bool> hasAcceptedApplicationsForProperty(String propertyId) async => false;
  @override
  Future<bool> deleteApplication(String applicationId) async => true;
  @override
  Future<bool> deleteApplicationsForProperty(String propertyId) async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepo authRepo;
  late MockApplicationRepo appRepo;
  late AuthProvider authProvider;
  late ApplicationProvider appProvider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    authRepo = MockAuthRepo();
    appRepo = MockApplicationRepo();

    final user = UserModel.fromJson(UserFixtures.validTenantJson);
    authRepo.currentUser = user;

    authProvider = AuthProvider(
      signInUseCase: SignInUseCase(authRepo),
      signUpUseCase: SignUpUseCase(authRepo),
      signOutUseCase: SignOutUseCase(authRepo),
      getCurrentUserUseCase: GetCurrentUserUseCase(authRepo),
      signInWithGoogleUseCase: SignInWithGoogleUseCase(authRepo),
      resetPasswordUseCase: ResetPasswordUseCase(authRepo),
      updateUserRoleUseCase: UpdateUserRoleUseCase(authRepo),
    );

    appProvider = ApplicationProvider(appRepo);
  });

  Widget buildTestApp({required String propertyType, String propertyTitle = 'Inmueble Test'}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<ApplicationProvider>.value(value: appProvider),
      ],
      child: MaterialApp(
        home: SolicitudDeArriendoPage(
          propertyId: 'prop_context_test_123',
          propertyTitle: propertyTitle,
          landlordId: 'usr_landlord_test',
          propertyType: propertyType,
        ),
      ),
    );
  }

  Future<void> addPersonalReference(WidgetTester tester) async {
    tester.testTextInput.hide();
    final refPanel = find.text('Referencias Personales');
    await tester.ensureVisible(refPanel);
    await tester.pumpAndSettle();
    await tester.tap(refPanel);
    await tester.pumpAndSettle();

    final addRefBtn = find.text('Agregar Referencia');
    await tester.ensureVisible(addRefBtn);
    await tester.pumpAndSettle();
    await tester.tap(addRefBtn);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Nombre completo'), 'Carlos Mendoza');
    await tester.enterText(find.widgetWithText(TextField, 'Teléfono'), '3101234567');
    await tester.enterText(find.widgetWithText(TextField, 'Relación (Amigo, Familiar, etc.)'), 'Amigo');
    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();
  }

  Future<void> acceptLegalAgreements(WidgetTester tester) async {
    tester.testTextInput.hide();
    final legalPanel = find.text('Acuerdos Legales');
    await tester.ensureVisible(legalPanel);
    await tester.pumpAndSettle();
    await tester.tap(legalPanel);
    await tester.pumpAndSettle();

    final terminos = find.text('Acepto los términos y condiciones de arriendo');
    await tester.ensureVisible(terminos);
    await tester.pumpAndSettle();
    await tester.tap(terminos);

    final privacidad = find.text('Acepto la política de privacidad y tratamiento de datos');
    await tester.ensureVisible(privacidad);
    await tester.pumpAndSettle();
    await tester.tap(privacidad);

    final autorizo = find.text('Autorizo la verificación de mi información laboral y referencias');
    await tester.ensureVisible(autorizo);
    await tester.pumpAndSettle();
    await tester.tap(autorizo);

    await tester.pumpAndSettle();
  }

  group('SolicitudDeArriendoPage Contextual Integration Tests [RF-13, RF-14, RF-15, RF-16, RNF-08, RNF-09, CL-13]', () {
    testWidgets('dynamically renders FormResidencialWidget for residential property [RF-13.1, RF-13.2]', (tester) async {
      await tester.pumpWidget(buildTestApp(propertyType: 'Apartamento'));
      await tester.pumpAndSettle();

      expect(find.text('Composición Familiar y Mascotas'), findsOneWidget);
      expect(find.byType(FormResidencialWidget), findsOneWidget);
      expect(find.byType(FormIndividualWidget), findsNothing);
      expect(find.byType(FormComercialWidget), findsNothing);

      // Verifies universal base fields are retained [RF-13.3]
      expect(find.text('Información Laboral y Financiera'), findsOneWidget);
      expect(find.text('Documentos Adjuntos'), findsOneWidget);
    });

    testWidgets('dynamically renders FormIndividualWidget for individual/room property [RF-13.1, RF-13.2]', (tester) async {
      await tester.pumpWidget(buildTestApp(propertyType: 'Habitación'));
      await tester.pumpAndSettle();

      expect(find.text('Información de Ocupación'), findsOneWidget);
      expect(find.byType(FormIndividualWidget), findsOneWidget);
      expect(find.byType(FormResidencialWidget), findsNothing);
      expect(find.byType(FormComercialWidget), findsNothing);
    });

    testWidgets('dynamically renders FormComercialWidget for commercial property [RF-13.1, RF-13.2]', (tester) async {
      await tester.pumpWidget(buildTestApp(propertyType: 'Local Comercial'));
      await tester.pumpAndSettle();

      expect(find.text('Información Comercial'), findsOneWidget);
      expect(find.byType(FormComercialWidget), findsOneWidget);
      expect(find.byType(FormResidencialWidget), findsNothing);
      expect(find.byType(FormIndividualWidget), findsNothing);
    });

    testWidgets('reactively displays pet details when pets switch is toggled [RF-14.3, RF-14.4, RNF-08]', (tester) async {
      await tester.pumpWidget(buildTestApp(propertyType: 'Casa'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('petDetailsField')), findsNothing);

      // Toggle switch to true
      final petSwitch = find.byType(SwitchListTile);
      expect(petSwitch, findsOneWidget);
      await tester.ensureVisible(petSwitch);
      await tester.pumpAndSettle();
      await tester.tap(petSwitch);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('petDetailsField')), findsOneWidget);

      // Toggle switch back to false
      await tester.tap(petSwitch);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('petDetailsField')), findsNothing);
    });

    testWidgets('reactively displays guardian fields for minor in individual form [RF-15.3, RF-15.4, RNF-08]', (tester) async {
      await tester.pumpWidget(buildTestApp(propertyType: 'Apartaestudio'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('guardianNameField')), findsNothing);
      expect(find.byKey(const Key('guardianPhoneField')), findsNothing);

      // Toggle minor switch
      final minorSwitch = find.byType(SwitchListTile);
      expect(minorSwitch, findsOneWidget);
      await tester.ensureVisible(minorSwitch);
      await tester.pumpAndSettle();
      await tester.tap(minorSwitch);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('guardianNameField')), findsOneWidget);
      expect(find.byKey(const Key('guardianPhoneField')), findsOneWidget);
      expect(find.byKey(const Key('guardianRelationshipDropdown')), findsOneWidget);
    });

    testWidgets('retains filled contextual and base data upon simulated network failure [RNF-09, CL-13]', (tester) async {
      appRepo.shouldFailCreate = true;

      await tester.pumpWidget(buildTestApp(propertyType: 'Casa Campestre'));
      await tester.pumpAndSettle();

      // Enter base info
      await tester.enterText(find.widgetWithText(TextFormField, 'Empresa donde trabaja'), 'Tech Solutions');
      await tester.enterText(find.widgetWithText(TextFormField, 'Cargo o posición'), 'Desarrollador Senior');
      await tester.enterText(find.widgetWithText(TextFormField, 'Tiempo en el empleo (meses)'), '24');
      await tester.enterText(find.widgetWithText(TextFormField, 'Ingreso mensual (COP)'), '6500000');

      // Scroll to contextual info and enter
      final occupantsField = find.byKey(const Key('occupantsField'));
      await tester.ensureVisible(occupantsField);
      await tester.pumpAndSettle();
      await tester.enterText(occupantsField, '4');

      final familyDescField = find.byKey(const Key('familyDescriptionField'));
      await tester.ensureVisible(familyDescField);
      await tester.pumpAndSettle();
      await tester.enterText(familyDescField, 'Pareja de esposos con dos hijos pequeños y una abuela');

      // Add a reference
      await addPersonalReference(tester);

      // Accept terms
      await acceptLegalAgreements(tester);

      // Submit
      final submitBtn = find.text('Enviar Solicitud');
      await tester.ensureVisible(submitBtn);
      await tester.pumpAndSettle();
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Error SnackBar displayed
      expect(find.textContaining('Fallo de conexión'), findsOneWidget);

      // Verify data is NOT lost (RNF-09)
      expect(appProvider.occupantsController.text, '4');
      expect(appProvider.familyDescriptionController.text, 'Pareja de esposos con dos hijos pequeños y una abuela');
    });

    testWidgets('prevents duplicate application submission if already applied [CL-10, CL-13]', (tester) async {
      appRepo.propertyHasActiveApplication = true;

      await tester.pumpWidget(buildTestApp(propertyType: 'Oficina Comercial'));
      await tester.pumpAndSettle();

      // Enter base info
      await tester.enterText(find.widgetWithText(TextFormField, 'Empresa donde trabaja'), 'Acme Corp');
      await tester.enterText(find.widgetWithText(TextFormField, 'Cargo o posición'), 'Gerente');
      await tester.enterText(find.widgetWithText(TextFormField, 'Tiempo en el empleo (meses)'), '36');
      await tester.enterText(find.widgetWithText(TextFormField, 'Ingreso mensual (COP)'), '12000000');

      // Enter commercial contextual info
      final bizField = find.byKey(const Key('businessNameField'));
      await tester.ensureVisible(bizField);
      await tester.pumpAndSettle();
      await tester.enterText(bizField, 'Acme Consulting S.A.S.');

      final nitField = find.byKey(const Key('nitField'));
      await tester.ensureVisible(nitField);
      await tester.pumpAndSettle();
      await tester.enterText(nitField, '900.123.456-7');

      final actField = find.byKey(const Key('economicActivityField'));
      await tester.ensureVisible(actField);
      await tester.pumpAndSettle();
      await tester.enterText(actField, 'Servicios de consultoría y desarrollo de software.');

      // Add a reference
      await addPersonalReference(tester);

      // Accept terms
      await acceptLegalAgreements(tester);

      // Submit
      final submitBtn = find.text('Enviar Solicitud');
      await tester.ensureVisible(submitBtn);
      await tester.pumpAndSettle();
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Shows duplicate error message
      expect(find.text('Ya tienes una solicitud en proceso para esta propiedad.'), findsOneWidget);
      expect(appRepo.lastCreatedApplication, isNull);
    });

    testWidgets('submits application successfully attaching CommercialContextData [RF-16, RF-13.1]', (tester) async {
      await tester.pumpWidget(buildTestApp(propertyType: 'Bodega'));
      await tester.pumpAndSettle();

      // Enter base info
      await tester.enterText(find.widgetWithText(TextFormField, 'Empresa donde trabaja'), 'Logística Andina');
      await tester.enterText(find.widgetWithText(TextFormField, 'Cargo o posición'), 'Director de Operaciones');
      await tester.enterText(find.widgetWithText(TextFormField, 'Tiempo en el empleo (meses)'), '18');
      await tester.enterText(find.widgetWithText(TextFormField, 'Ingreso mensual (COP)'), '15000000');

      // Enter commercial contextual info
      final bizField = find.byKey(const Key('businessNameField'));
      await tester.ensureVisible(bizField);
      await tester.pumpAndSettle();
      await tester.enterText(bizField, 'Logística y Carga Andina S.A.S.');

      final nitField = find.byKey(const Key('nitField'));
      await tester.ensureVisible(nitField);
      await tester.pumpAndSettle();
      await tester.enterText(nitField, '901.888.777-1');

      final actField = find.byKey(const Key('economicActivityField'));
      await tester.ensureVisible(actField);
      await tester.pumpAndSettle();
      await tester.enterText(actField, 'Almacenamiento, distribución y logística de mercancías secas.');

      // Add a reference
      await addPersonalReference(tester);

      // Accept terms
      await acceptLegalAgreements(tester);

      // Submit
      final submitBtn = find.text('Enviar Solicitud');
      await tester.ensureVisible(submitBtn);
      await tester.pumpAndSettle();
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Dialog is shown
      expect(find.text('¡Solicitud Enviada!'), findsOneWidget);

      // Verify payload has CommercialContextData
      expect(appRepo.lastCreatedApplication, isNotNull);
      final ctx = appRepo.lastCreatedApplication!.datosContextuales;
      expect(ctx, isA<CommercialContextData>());
      final comCtx = ctx as CommercialContextData;
      expect(comCtx.razonSocial, 'Logística y Carga Andina S.A.S.');
      expect(comCtx.nit, '901.888.777-1');
      expect(comCtx.actividadEconomica, 'Almacenamiento, distribución y logística de mercancías secas.');
    });
  });
}
