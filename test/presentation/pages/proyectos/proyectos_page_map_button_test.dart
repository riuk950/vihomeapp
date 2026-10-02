import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/entities/project.dart';
import 'package:vihomeapp/domain/entities/user.dart';
import 'package:vihomeapp/domain/repositories/application_repository.dart';
import 'package:vihomeapp/domain/repositories/auth_repository.dart';
import 'package:vihomeapp/domain/repositories/project_repository.dart';
import 'package:vihomeapp/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/reset_password_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_in_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_in_with_google_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_out_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_up_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/update_user_role_usecase.dart';
import 'package:vihomeapp/domain/usecases/project/get_projects_usecase.dart';
import 'package:vihomeapp/presentation/pages/proyectos/proyectos_page.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/presentation/providers/project_provider.dart';

import 'package:vihomeapp/domain/entities/constructora.dart';
import 'package:vihomeapp/core/di/injection_container.dart';
import 'package:vihomeapp/core/ads/ad_manager.dart';

class MockProjectRepository implements ProjectRepository {
  List<Project> projects = [];

  @override
  Future<List<Project>> getProjects() async => projects;

  @override
  Future<Constructora> getConstructora(String id) async => const Constructora(
        id: 'const-1',
        nombre: 'Constructora Test',
        nit: '900123456',
      );
}

class MockAppRepository implements ApplicationRepository {
  @override
  Future<List<Application>> getLandlordApplications(String landlordId) async =>
      [];
  @override
  Future<List<Application>> getTenantApplications(String tenantId) async => [];
  @override
  Future<bool> updateApplicationStatus(
          String applicationId, String status) async =>
      true;
  @override
  Future<Application> createApplication(Application application) async =>
      application;
  @override
  Future<bool> hasApplicationForProperty(
          String tenantId, String propertyId) async =>
      false;
  @override
  Future<bool> hasAcceptedApplicationsForProperty(String propertyId) async =>
      false;
  @override
  Future<bool> deleteApplicationsForProperty(String propertyId) async => true;
  @override
  Future<bool> deleteApplication(String applicationId) async => true;
}

class MockAuthRepository implements AuthRepository {
  User? user;

  @override
  Future<Either<Failure, User?>> getCurrentUser() async => Right(user);
  @override
  Future<Either<Failure, User>> signInWithEmail(
          {required String email, required String password}) async =>
      Right(user!);
  @override
  Future<Either<Failure, User>> signUp(
          {required String email,
          required String password,
          Map<String, dynamic>? metadata}) async =>
      Right(user!);
  @override
  Future<Either<Failure, void>> signOut() async {
    user = null;
    return const Right(null);
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async =>
      const Left(AuthFailure('error'));
  @override
  Future<Either<Failure, void>> resetPassword(String email) async =>
      const Right(null);
  @override
  Future<Either<Failure, void>> updatePassword(String newPassword) async =>
      const Right(null);
  @override
  Future<Either<Failure, void>> updateUserRole(String role) async =>
      const Right(null);
  @override
  Stream<Either<Failure, User?>> authStateChanges() => Stream.value(Right(user));
}

void main() {
  late MockProjectRepository mockProjectRepo;
  late MockAppRepository mockAppRepo;
  late MockAuthRepository mockAuthRepo;
  late ProjectProvider projectProvider;
  late ApplicationProvider appProvider;
  late AuthProvider authProvider;

  setUp(() {
    if (getIt.isRegistered<AdManager>()) getIt.unregister<AdManager>();
    getIt.registerSingleton<AdManager>(AdManager());

    mockProjectRepo = MockProjectRepository();
    mockAppRepo = MockAppRepository();
    mockAuthRepo = MockAuthRepository();

    projectProvider = ProjectProvider(
      getProjectsUseCase: GetProjectsUseCase(mockProjectRepo),
    );
    appProvider = ApplicationProvider(mockAppRepo);
    authProvider = AuthProvider(
      signInUseCase: SignInUseCase(mockAuthRepo),
      signUpUseCase: SignUpUseCase(mockAuthRepo),
      signOutUseCase: SignOutUseCase(mockAuthRepo),
      getCurrentUserUseCase: GetCurrentUserUseCase(mockAuthRepo),
      signInWithGoogleUseCase: SignInWithGoogleUseCase(mockAuthRepo),
      resetPasswordUseCase: ResetPasswordUseCase(mockAuthRepo),
      updateUserRoleUseCase: UpdateUserRoleUseCase(mockAuthRepo),
    );
  });

  tearDown(() {
    if (getIt.isRegistered<AdManager>()) getIt.unregister<AdManager>();
  });

  Widget createWidgetUnderTest({GoRouter? customRouter}) {
    final router = customRouter ??
        GoRouter(
          initialLocation: '/proyectos',
          routes: [
            GoRoute(
              path: '/proyectos',
              builder: (context, state) => const ProyectosPage(),
            ),
            GoRoute(
              path: '/mapa',
              name: 'mapa',
              builder: (context, state) {
                final tipo = state.uri.queryParameters['tipo'];
                return Scaffold(
                  body: Text('Ruta Mapa - Tipo: $tipo'),
                );
              },
            ),
          ],
        );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProjectProvider>.value(value: projectProvider),
        ChangeNotifierProvider<ApplicationProvider>.value(value: appProvider),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('ProyectosPage Map Button Tests [RF-42.1, RF-42.2, RF-42.3, RNF-28, DT-5]', () {
    testWidgets('renders map icon button with tooltip "Ver Proyectos en Mapa"',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final mapButtonFinder = find.byTooltip('Ver Proyectos en Mapa');
      expect(mapButtonFinder, findsOneWidget);

      final iconFinder = find.widgetWithIcon(IconButton, Icons.map_outlined);
      expect(iconFinder, findsOneWidget);
    });

    testWidgets('tapping map icon button navigates to /mapa?tipo=proyectos',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final mapButtonFinder = find.byTooltip('Ver Proyectos en Mapa');
      await tester.tap(mapButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Ruta Mapa - Tipo: proyectos'), findsOneWidget);
    });
  });
}
