import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/domain/entities/guest_redirect_context.dart';
import 'package:vihomeapp/domain/entities/user.dart';
import 'package:vihomeapp/presentation/pages/user/login_page.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/presentation/providers/subscription_provider.dart';
import 'package:vihomeapp/presentation/widgets/guest_auth_banner.dart';

class _LoginFakeAuthProvider extends ChangeNotifier implements AuthProvider {
  User? _user;
  String? _errorMessage;
  bool shouldSucceedLogin = true;

  @override
  User? get user => _user;

  @override
  bool get isAuthenticated => _user != null;

  @override
  bool get isGuest => !isAuthenticated;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => _errorMessage;

  @override
  void clearError() {
    _errorMessage = null;
  }

  @override
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (shouldSucceedLogin) {
      _user = User(id: 'u-1', email: email, role: 'arrendatario');
      notifyListeners();
      return true;
    }
    _errorMessage = 'Credenciales inválidas';
    notifyListeners();
    return false;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSubscriptionProvider extends SubscriptionProvider {
  @override
  Future<void> initialize(String? userId) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoginPage - Experiencia para Rol Invitado (RF-1.3, RF-3.2, RF-6, RF-7, RNF-4, RNF-5)', () {
    testWidgets('Muestra GuestAuthBanner cuando proviene de restricción de invitado (RF-3.2, RF-4.2)', (tester) async {
      final authProvider = _LoginFakeAuthProvider();
      final router = GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => LoginPage(
              redirectContext: GuestRedirectContext.fromReason(
                GuestRedirectReason.rentApplication,
                sourcePath: '/property-details',
              ),
            ),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(body: Text('HOME_PAGE')),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<SubscriptionProvider>(
              create: (_) => _FakeSubscriptionProvider(),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GuestAuthBanner), findsOneWidget);
      expect(
        find.text(GuestRedirectReason.rentApplication.defaultBannerMessage!),
        findsOneWidget,
      );
      expect(find.byKey(const Key('continue_as_guest_button')), findsOneWidget);
    });

    testWidgets('Oculta GuestAuthBanner cuando proviene del enlace Iniciar Sesión del onboarding (RF-1.3)', (tester) async {
      final authProvider = _LoginFakeAuthProvider();
      final router = GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => LoginPage(
              redirectContext: GuestRedirectContext.onboardingShortcut(),
            ),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(body: Text('HOME_PAGE')),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<SubscriptionProvider>(
              create: (_) => _FakeSubscriptionProvider(),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GuestAuthBanner), findsNothing);

      // Sin historial previo, "Continuar como invitado" dirige a /home (RF-6.3)
      final guestBtn = find.byKey(const Key('continue_as_guest_button'));
      await tester.ensureVisible(guestBtn);
      await tester.tap(guestBtn);
      await tester.pumpAndSettle();

      expect(find.text('HOME_PAGE'), findsOneWidget);
    });

    testWidgets('Regresa por pop a la vista pública previa con "Continuar como invitado" y "Atrás", incluso tras error de login (RF-6.2, RF-6.5)', (tester) async {
      final authProvider = _LoginFakeAuthProvider()..shouldSucceedLogin = false;
      final router = GoRouter(
        initialLocation: '/detail',
        routes: [
          GoRoute(
            path: '/detail',
            builder: (context, state) => Scaffold(
              body: ElevatedButton(
                onPressed: () => context.push(
                  '/login',
                  extra: GuestRedirectContext.fromReason(
                    GuestRedirectReason.profile,
                    sourcePath: '/home',
                  ),
                ),
                child: const Text('OPEN_LOGIN'),
              ),
            ),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => LoginPage(
              redirectContext: state.extra as GuestRedirectContext?,
            ),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(body: Text('HOME_PAGE')),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<SubscriptionProvider>(
              create: (_) => _FakeSubscriptionProvider(),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('OPEN_LOGIN'));
      await tester.pumpAndSettle();

      // Simular intento fallido de inicio de sesión
      await tester.enterText(find.byType(TextFormField).first, 'user@test.com');
      await tester.enterText(find.byType(TextFormField).last, '123456');
      final submitBtn = find.widgetWithText(ElevatedButton, 'Iniciar Sesión');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Credenciales inválidas'), findsOneWidget);

      // Pulsar botón atrás debe devolver a /detail (RF-6.2, RF-6.5)
      await tester.tap(find.byKey(const Key('login_back_button')));
      await tester.pumpAndSettle();

      expect(find.text('OPEN_LOGIN'), findsOneWidget);
    });

    testWidgets('Login exitoso redirige siempre a /home limpiando la pila previa (RF-7.1, RF-7.2)', (tester) async {
      final authProvider = _LoginFakeAuthProvider()..shouldSucceedLogin = true;
      final router = GoRouter(
        initialLocation: '/detail',
        routes: [
          GoRoute(
            path: '/detail',
            builder: (context, state) => Scaffold(
              body: ElevatedButton(
                onPressed: () => context.push(
                  '/login',
                  extra: GuestRedirectContext.fromReason(
                    GuestRedirectReason.rentApplication,
                    sourcePath: '/property-details',
                  ),
                ),
                child: const Text('OPEN_LOGIN'),
              ),
            ),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => LoginPage(
              redirectContext: state.extra as GuestRedirectContext?,
            ),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(body: Text('HOME_PAGE')),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<SubscriptionProvider>(
              create: (_) => _FakeSubscriptionProvider(),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('OPEN_LOGIN'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'user@test.com');
      await tester.enterText(find.byType(TextFormField).last, '123456');
      final submitBtn = find.widgetWithText(ElevatedButton, 'Iniciar Sesión');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('HOME_PAGE'), findsOneWidget);
      expect(authProvider.isAuthenticated, isTrue);
    });

    testWidgets('Accesibilidad y responsividad en pantalla compacta 320x568 con texto escalado (RNF-5)', (tester) async {
      tester.view.physicalSize = const Size(320 * 2, 568 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final authProvider = _LoginFakeAuthProvider();
      final router = GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.4),
              ),
              child: LoginPage(
                redirectContext: GuestRedirectContext.fromReason(
                  GuestRedirectReason.profile,
                  sourcePath: '/home',
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(body: Text('HOME_PAGE')),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<SubscriptionProvider>(
              create: (_) => _FakeSubscriptionProvider(),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final guestBtnSize = tester.getSize(find.byKey(const Key('continue_as_guest_button')));
      expect(guestBtnSize.height, greaterThanOrEqualTo(48.0));
      final backBtnSize = tester.getSize(find.byKey(const Key('login_back_button')));
      expect(backBtnSize.width, greaterThanOrEqualTo(48.0));
      expect(backBtnSize.height, greaterThanOrEqualTo(48.0));
    });
  });
}
