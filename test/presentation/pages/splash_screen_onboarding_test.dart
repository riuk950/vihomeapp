import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/domain/entities/onboarding_state.dart';
import 'package:vihomeapp/domain/entities/user.dart';
import 'package:vihomeapp/domain/repositories/auth_repository.dart';
import 'package:vihomeapp/domain/repositories/onboarding_repository.dart';
import 'package:vihomeapp/domain/usecases/auth/delete_account_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/reset_password_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_in_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_in_with_google_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_out_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_up_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/update_user_role_usecase.dart';
import 'package:vihomeapp/domain/usecases/onboarding/complete_onboarding_usecase.dart';
import 'package:vihomeapp/domain/usecases/onboarding/get_onboarding_status_usecase.dart';
import 'package:vihomeapp/presentation/pages/navegation/splash_screen.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/presentation/providers/subscription_provider.dart';

class FakeAuthRepo implements AuthRepository {
  User? user;
  bool shouldThrowOnGetCurrentUser;
  FakeAuthRepo({this.user, this.shouldThrowOnGetCurrentUser = false});

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    if (shouldThrowOnGetCurrentUser) {
      throw Exception('Session expired or check failed');
    }
    return Right(user);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeOnboardingRepo implements OnboardingRepository {
  OnboardingState stateToReturn = OnboardingState.notSeen();
  bool shouldThrow = false;
  OnboardingCompletionReason? markedReason;

  @override
  Future<OnboardingState> getOnboardingState() async {
    if (shouldThrow) throw Exception('Read failed');
    return stateToReturn;
  }

  @override
  Future<bool> markOnboardingSeen({
    required OnboardingCompletionReason reason,
    required int lastStep,
  }) async {
    markedReason = reason;
    return true;
  }
}

class FakeSubscriptionProvider extends SubscriptionProvider {
  @override
  Future<void> initialize(String? userId) async {
    // No-op para pruebas unitarias sin Supabase real
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final getIt = GetIt.instance;

  late FakeOnboardingRepo fakeOnboardingRepo;

  setUp(() async {
    await getIt.reset();
    fakeOnboardingRepo = FakeOnboardingRepo();
    getIt.registerLazySingleton<GetOnboardingStatusUseCase>(
      () => GetOnboardingStatusUseCase(fakeOnboardingRepo),
    );
    getIt.registerLazySingleton<CompleteOnboardingUseCase>(
      () => CompleteOnboardingUseCase(fakeOnboardingRepo),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildTestApp({
    required AuthProvider authProvider,
    required String? Function() currentRouteGetter,
  }) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const Scaffold(body: Text('ONBOARDING_SCREEN')),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('LOGIN_SCREEN')),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Text('HOME_SCREEN')),
        ),
      ],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<SubscriptionProvider>(
          create: (_) => FakeSubscriptionProvider(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  AuthProvider createAuthProvider({
    User? user,
    bool shouldThrowOnGetCurrentUser = false,
  }) {
    final repo = FakeAuthRepo(
      user: user,
      shouldThrowOnGetCurrentUser: shouldThrowOnGetCurrentUser,
    );
    return AuthProvider(
      getCurrentUserUseCase: GetCurrentUserUseCase(repo),
      signInUseCase: SignInUseCase(repo),
      signInWithGoogleUseCase: SignInWithGoogleUseCase(repo),
      signUpUseCase: SignUpUseCase(repo),
      signOutUseCase: SignOutUseCase(repo),
      deleteAccountUseCase: DeleteAccountUseCase(repo),
      resetPasswordUseCase: ResetPasswordUseCase(repo),
      updateUserRoleUseCase: UpdateUserRoleUseCase(repo),
    );
  }

  group('SplashScreen - Enrutamiento Inicial con Onboarding (RF-1)', () {
    testWidgets('1. Usuario no autenticado que no ha visto onboarding navega a /onboarding (RF-1.1)', (tester) async {
      fakeOnboardingRepo.stateToReturn = OnboardingState.notSeen();
      final authProvider = createAuthProvider(user: null);

      String? currentRoute;
      await tester.pumpWidget(
        buildTestApp(
          authProvider: authProvider,
          currentRouteGetter: () => currentRoute,
        ),
      );

      // Esperar la inicialización y el delay mínimo del splash (2000 ms)
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 2100));
      await tester.pumpAndSettle();

      expect(find.text('ONBOARDING_SCREEN'), findsOneWidget);
    });

    testWidgets('2. Usuario no autenticado que ya vio onboarding navega directamente a /home en modo invitado (012 RF-1.4)', (tester) async {
      fakeOnboardingRepo.stateToReturn = const OnboardingState(
        hasSeenOnboarding: true,
        completionReason: OnboardingCompletionReason.completed,
        lastCompletedStep: 4,
      );
      final authProvider = createAuthProvider(user: null);

      await tester.pumpWidget(
        buildTestApp(
          authProvider: authProvider,
          currentRouteGetter: () => null,
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 2100));
      await tester.pumpAndSettle();

      expect(find.text('HOME_SCREEN'), findsOneWidget);
    });

    testWidgets('3. Usuario autenticado tras actualización marca onboarding como visto y navega a /home (RF-1.3)', (tester) async {
      fakeOnboardingRepo.stateToReturn = OnboardingState.notSeen();
      final authProvider = createAuthProvider(
        user: const User(id: 'usr_existing', email: 'existing@vihome.app', name: 'Existing'),
      );

      await tester.pumpWidget(
        buildTestApp(
          authProvider: authProvider,
          currentRouteGetter: () => null,
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 2100));
      await tester.pumpAndSettle();

      expect(fakeOnboardingRepo.markedReason, OnboardingCompletionReason.existingSession);
      expect(find.text('HOME_SCREEN'), findsOneWidget);
    });

    testWidgets('4. Error al leer onboarding sin sesión aplica respaldo determinista a /onboarding (RF-8.3)', (tester) async {
      fakeOnboardingRepo.shouldThrow = true;
      final authProvider = createAuthProvider(user: null);

      await tester.pumpWidget(
        buildTestApp(
          authProvider: authProvider,
          currentRouteGetter: () => null,
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 2100));
      await tester.pumpAndSettle();

      expect(find.text('ONBOARDING_SCREEN'), findsOneWidget);
    });

    testWidgets('5. Error o sesión expirada al inicializar con onboarding visto entra en modo invitado en /home (012 RF-1.5, RF-1.6)', (tester) async {
      fakeOnboardingRepo.stateToReturn = const OnboardingState(
        hasSeenOnboarding: true,
        completionReason: OnboardingCompletionReason.completed,
        lastCompletedStep: 4,
      );
      final authProvider = createAuthProvider(shouldThrowOnGetCurrentUser: true);

      await tester.pumpWidget(
        buildTestApp(
          authProvider: authProvider,
          currentRouteGetter: () => null,
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 2100));
      await tester.pumpAndSettle();

      expect(authProvider.isGuest, isTrue);
      expect(find.text('HOME_SCREEN'), findsOneWidget);
    });
  });
}
