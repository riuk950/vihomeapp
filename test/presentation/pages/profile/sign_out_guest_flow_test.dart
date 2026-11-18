import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/entities/landlord.dart';
import 'package:vihomeapp/domain/entities/review.dart';
import 'package:vihomeapp/domain/entities/tenant.dart';
import 'package:vihomeapp/domain/entities/user.dart';
import 'package:vihomeapp/domain/entities/user_reputation.dart';
import 'package:vihomeapp/domain/repositories/review_repository.dart';
import 'package:vihomeapp/presentation/pages/navegation/panel_page.dart';
import 'package:vihomeapp/presentation/pages/navegation/perfil_page.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/presentation/providers/landlord_provider.dart';
import 'package:vihomeapp/presentation/providers/review_provider.dart';
import 'package:vihomeapp/presentation/providers/subscription_provider.dart';
import 'package:vihomeapp/presentation/providers/tenant_provider.dart';

class _MockReviewRepo implements ReviewRepository {
  @override
  Future<UserReputation> getUserReputation(
    String userId, {
    bool isVerified = false,
    String? userName,
  }) async =>
      UserReputation(userId: userId, userName: userName, isVerified: isVerified);

  @override
  Future<List<Review>> getUserReviews(String userId) async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  User? _user;
  bool signOutCalled = false;

  _FakeAuthProvider({User? user}) : _user = user;

  @override
  User? get user => _user;

  @override
  bool get isAuthenticated => _user != null;

  @override
  bool get isGuest => !isAuthenticated;

  @override
  bool get isLoading => false;

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    _user = null;
    notifyListeners();
  }

  @override
  Future<void> reloadUser() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTenantProvider extends ChangeNotifier implements TenantProvider {
  bool cleared = false;
  @override
  bool get isVerified => false;
  @override
  bool get isLoading => false;
  @override
  Tenant? get tenant => null;
  @override
  Future<void> loadTenantProfile(String userId) async {}
  @override
  void clear() => cleared = true;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLandlordProvider extends ChangeNotifier implements LandlordProvider {
  bool cleared = false;
  @override
  bool get isVerified => false;
  @override
  bool get isLoading => false;
  @override
  Landlord? get landlord => null;
  @override
  Future<void> loadLandlordProfile(String userId) async {}
  @override
  void clear() => cleared = true;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeApplicationProvider extends ChangeNotifier
    implements ApplicationProvider {
  bool cleared = false;
  @override
  List<Application> get applications => [];
  @override
  bool get isLoading => false;
  @override
  Future<void> fetchLandlordApplications(String landlordId,
      {bool silent = false}) async {}
  @override
  Future<void> fetchTenantApplications(String tenantId,
      {bool silent = false}) async {}
  @override
  void clear() => cleared = true;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSubscriptionProvider extends SubscriptionProvider {
  bool cleared = false;
  @override
  void clear() {
    cleared = true;
    super.clear();
  }
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    dotenv.testLoad(fileInput: '''
DEBUG_MODE=true
MAPBOX_ACCESS_TOKEN=
ADMOB_BANNER_ID=ca-app-pub-test
API_BASE_URL=https://api.example.com
''');
  });

  group('Cierre de sesión -> retorno a /home en modo invitado (RF-7.3)', () {
    testWidgets('Cerrar sesión desde PerfilPage limpia providers y navega a /home', (tester) async {
      final authProvider = _FakeAuthProvider(
        user: const User(id: 'u1', email: 't@v.com', role: 'arrendatario'),
      );
      final tenantProvider = _FakeTenantProvider();
      final landlordProvider = _FakeLandlordProvider();
      final appProvider = _FakeApplicationProvider();
      final subProvider = _FakeSubscriptionProvider();

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: PerfilPage()),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                const Scaffold(body: Text('HOME_GUEST_ARRIENDOS')),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<TenantProvider>.value(value: tenantProvider),
            ChangeNotifierProvider<LandlordProvider>.value(value: landlordProvider),
            ChangeNotifierProvider<ApplicationProvider>.value(value: appProvider),
            ChangeNotifierProvider<SubscriptionProvider>.value(value: subProvider),
            ChangeNotifierProvider<ReviewProvider>(
              create: (_) => ReviewProvider(_MockReviewRepo()),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      final logoutBtn = find.text('Cerrar sesión');
      await tester.scrollUntilVisible(logoutBtn, 200);
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      // Confirmar diálogo de cierre de sesión
      await tester.tap(find.text('Cerrar sesión').last);
      await tester.pumpAndSettle();

      expect(authProvider.signOutCalled, isTrue);
      expect(authProvider.isGuest, isTrue);
      expect(tenantProvider.cleared, isTrue);
      expect(landlordProvider.cleared, isTrue);
      expect(appProvider.cleared, isTrue);
      expect(subProvider.cleared, isTrue);
      expect(find.text('HOME_GUEST_ARRIENDOS'), findsOneWidget);
    });

    testWidgets('Cerrar sesión desde PanelPage limpia providers y navega a /home', (tester) async {
      final authProvider = _FakeAuthProvider(
        user: const User(id: 'u2', email: 'l@v.com', role: 'arrendador'),
      );
      final tenantProvider = _FakeTenantProvider();
      final landlordProvider = _FakeLandlordProvider();
      final appProvider = _FakeApplicationProvider();
      final subProvider = _FakeSubscriptionProvider();

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: PanelPage()),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                const Scaffold(body: Text('HOME_GUEST_ARRIENDOS')),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<TenantProvider>.value(value: tenantProvider),
            ChangeNotifierProvider<LandlordProvider>.value(value: landlordProvider),
            ChangeNotifierProvider<ApplicationProvider>.value(value: appProvider),
            ChangeNotifierProvider<SubscriptionProvider>.value(value: subProvider),
            ChangeNotifierProvider<ReviewProvider>(
              create: (_) => ReviewProvider(_MockReviewRepo()),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      final logoutBtn = find.text('Cerrar Sesión');
      await tester.scrollUntilVisible(logoutBtn, 200);
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cerrar Sesión').last);
      await tester.pumpAndSettle();

      expect(authProvider.signOutCalled, isTrue);
      expect(authProvider.isGuest, isTrue);
      expect(tenantProvider.cleared, isTrue);
      expect(landlordProvider.cleared, isTrue);
      expect(appProvider.cleared, isTrue);
      expect(subProvider.cleared, isTrue);
      expect(find.text('HOME_GUEST_ARRIENDOS'), findsOneWidget);
    });
  });
}
