import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/data/models/user_model.dart';
import 'package:vihomeapp/domain/entities/application.dart';
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

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<ApplicationProvider>.value(value: appProvider),
      ],
      child: const MaterialApp(
        home: SolicitudDeArriendoPage(
          propertyId: 'prop_8f3a1290',
          propertyTitle: 'Apartamento moderno en Chapinero',
          landlordId: 'usr_landlord_99',
        ),
      ),
    );
  }

  group('SolicitudDeArriendoPage Widget Tests [RF-10.1, RF-10.2, RF-10.3, RF-10.4, CL-06]', () {
    testWidgets('renders all form sections and property header [RF-10.4]', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Solicitud de Arriendo'), findsOneWidget);
      expect(find.text('Apartamento moderno en Chapinero'), findsOneWidget);
      expect(find.text('Información Laboral y Financiera'), findsOneWidget);
      expect(find.text('Documentos Adjuntos'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Enviar Solicitud'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Enviar Solicitud'), findsOneWidget);
    });

    testWidgets('formats currency in income input field with thousand separators [RF-10.1]', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final incomeField = find.widgetWithText(TextFormField, 'Ingreso mensual (COP)');
      expect(incomeField, findsOneWidget);

      await tester.enterText(incomeField, '2500000');
      await tester.pump();

      expect(find.text('2.500.000'), findsOneWidget);
    });

    testWidgets('validates required fields on submission when empty [RF-10.4]', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Enviar Solicitud'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      final submitBtn = find.text('Enviar Solicitud');
      await tester.tap(submitBtn);
      await tester.pump();

      expect(find.text('Este campo es requerido'), findsWidgets);
    });
  });
}
