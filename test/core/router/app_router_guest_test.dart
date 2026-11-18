import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/core/router/app_router.dart';
import 'package:vihomeapp/domain/entities/guest_redirect_context.dart';
import 'package:vihomeapp/domain/entities/user.dart';
import 'package:vihomeapp/env/env_def.dart';
import 'package:vihomeapp/presentation/pages/user/login_page.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/presentation/widgets/guest_auth_banner.dart';

class _RouterFakeAuthProvider extends ChangeNotifier implements AuthProvider {
  User? _user;
  bool _expired = false;

  _RouterFakeAuthProvider({User? user}) : _user = user;

  @override
  User? get user => _user;

  @override
  bool get isAuthenticated => _user != null;

  @override
  bool get isGuest => !isAuthenticated;

  @override
  bool get isLoading => false;

  @override
  bool get hasExpiredSession => _expired;

  @override
  void consumeSessionExpiredFlag() {
    _expired = false;
  }

  @override
  void clearError() {}

  @override
  String? get errorMessage => null;

  void expireSession() {
    _user = null;
    _expired = true;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    EnvDef.setFlavor('dev');
    dotenv.testLoad(fileInput: '''
DEBUG_MODE=true
MAPBOX_ACCESS_TOKEN=pk.test1234
ADMOB_BANNER_ID=ca-app-pub-test
API_BASE_URL=https://api.example.com
''');
  });

  group('AppRouter - Políticas de Acceso Público y Privado para Rol Invitado', () {
    test('kPublicAppRoutes contiene exactamente las rutas públicas definidas en plan.md', () {
      expect(
        kPublicAppRoutes,
        containsAll([
          '/',
          '/onboarding',
          '/login',
          '/register',
          '/home',
          '/property-details',
          '/proyecto-detalle',
          '/mapa',
        ]),
      );
      expect(kPublicAppRoutes.contains('/solicitud-arriendo'), isFalse);
      expect(kPublicAppRoutes.contains('/complete-profile'), isFalse);
      expect(kPublicAppRoutes.contains('/mis-propiedades'), isFalse);
      expect(kPublicAppRoutes.contains('/subscription'), isFalse);
    });

    testWidgets('Invitado intentando acceder a ruta privada redirige a /login con banner de restricción (RF-5.1, RNF-2)', (tester) async {
      final authProvider = _RouterFakeAuthProvider(user: null);
      final router = createAppRouter(
        initialLocation: '/solicitud-arriendo',
        refreshListenable: authProvider,
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(GuestAuthBanner), findsOneWidget);
      expect(
        find.text(GuestRedirectReason.privateRoute.defaultBannerMessage!),
        findsOneWidget,
      );
    });

    testWidgets('Expiración de sesión en caliente estando en ruta privada redirige a /login con aviso session_expired (RF-1.7)', (tester) async {
      final authProvider = _RouterFakeAuthProvider(
        user: const User(id: 'u1', email: 'a@b.com', role: 'arrendatario'),
      );
      final router = createAppRouter(
        initialLocation: '/debug',
        refreshListenable: authProvider,
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Debug Info'), findsOneWidget);

      authProvider.expireSession();
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(
        find.text(GuestRedirectReason.sessionExpired.defaultBannerMessage!),
        findsOneWidget,
      );
    });
  });
}
