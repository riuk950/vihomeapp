import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/entities/landlord.dart';
import 'package:vihomeapp/domain/entities/tenant.dart';
import 'package:vihomeapp/domain/entities/user.dart';
import 'package:vihomeapp/domain/entities/user_reputation.dart';
import 'package:vihomeapp/domain/entities/review.dart';
import 'package:vihomeapp/domain/repositories/review_repository.dart';
import 'package:vihomeapp/presentation/pages/navegation/perfil_page.dart';
import 'package:vihomeapp/presentation/pages/navegation/panel_page.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/presentation/providers/landlord_provider.dart';
import 'package:vihomeapp/presentation/providers/review_provider.dart';
import 'package:vihomeapp/presentation/providers/tenant_provider.dart';

class MockReviewRepo implements ReviewRepository {
  @override
  Future<Review> createReview({
    required String solicitudId,
    required String reviewerId,
    required String targetUserId,
    required int rating,
    String? comment,
    String? reviewerName,
  }) async =>
      throw UnimplementedError();

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
  Future<bool> canUserRateApplication({
    required String solicitudId,
    required String userId,
  }) async =>
      false;

  @override
  Future<Review> registerVerifiedUserReview({
    required String userId,
    String? userName,
  }) async =>
      throw UnimplementedError();
}

class FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  User? _user;
  bool deleteAccountCalled = false;
  bool deleteAccountReturn = true;

  @override
  User? get user => _user;
  set user(User? u) {
    _user = u;
    notifyListeners();
  }

  @override
  String? get errorMessage => null;

  @override
  bool get isLoading => false;

  @override
  bool get isAuthenticated => _user != null;

  @override
  Future<bool> deleteAccount() async {
    deleteAccountCalled = true;
    if (deleteAccountReturn) {
      _user = null;
      notifyListeners();
    }
    return deleteAccountReturn;
  }

  @override
  Future<void> reloadUser() async {}

  @override
  Future<void> signOut() async {
    _user = null;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeTenantProvider extends ChangeNotifier implements TenantProvider {
  @override
  bool get isVerified => false;

  @override
  bool get isLoading => false;

  @override
  Tenant? get tenant => null;

  @override
  Future<void> loadTenantProfile(String userId) async {}

  @override
  void clear() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeLandlordProvider extends ChangeNotifier implements LandlordProvider {
  @override
  bool get isVerified => false;

  @override
  bool get isLoading => false;

  @override
  Landlord? get landlord => null;

  @override
  Future<void> loadLandlordProfile(String userId) async {}

  @override
  void clear() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeApplicationProvider extends ChangeNotifier implements ApplicationProvider {
  @override
  List<Application> get applications => [];

  @override
  bool get isLoading => false;

  @override
  Future<void> fetchLandlordApplications(String landlordId, {bool silent = false}) async {}

  @override
  Future<void> fetchTenantApplications(String tenantId, {bool silent = false}) async {}

  @override
  void clear() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    dotenv.testLoad(fileInput: '''
DEBUG_MODE=true
MAPBOX_ACCESS_TOKEN=pk.test1234
ADMOB_BANNER_ID=ca-app-pub-test
API_BASE_URL=https://api.example.com
''');
  });

  late FakeAuthProvider fakeAuthProvider;
  late FakeTenantProvider fakeTenantProvider;
  late FakeLandlordProvider fakeLandlordProvider;
  late FakeApplicationProvider fakeAppProvider;
  late ReviewProvider reviewProvider;

  setUp(() {
    fakeAuthProvider = FakeAuthProvider();
    fakeTenantProvider = FakeTenantProvider();
    fakeLandlordProvider = FakeLandlordProvider();
    fakeAppProvider = FakeApplicationProvider();
    reviewProvider = ReviewProvider(MockReviewRepo());
  });

  Widget buildPerfilWidget() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: PerfilPage()),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Login Screen')),
        ),
      ],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: fakeAuthProvider),
        ChangeNotifierProvider<TenantProvider>.value(value: fakeTenantProvider),
        ChangeNotifierProvider<LandlordProvider>.value(value: fakeLandlordProvider),
        ChangeNotifierProvider<ApplicationProvider>.value(value: fakeAppProvider),
        ChangeNotifierProvider<ReviewProvider>.value(value: reviewProvider),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  Widget buildPanelWidget() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: PanelPage()),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Login Screen')),
        ),
      ],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: fakeAuthProvider),
        ChangeNotifierProvider<TenantProvider>.value(value: fakeTenantProvider),
        ChangeNotifierProvider<LandlordProvider>.value(value: fakeLandlordProvider),
        ChangeNotifierProvider<ApplicationProvider>.value(value: fakeAppProvider),
        ChangeNotifierProvider<ReviewProvider>.value(value: reviewProvider),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('Flujo de Eliminación de Cuenta en PerfilPage (Arrendatario) [RF-52, RF-54, CA-1, CA-2, CA-4, CL-52]', () {
    testWidgets('Muestra la opción "Eliminar cuenta" en PerfilPage y abre el diálogo modal de confirmación [CA-1, CA-2]', (tester) async {
      fakeAuthProvider.user = const User(
        id: 'usr-1',
        email: 'tenant@vihome.app',
        role: 'arrendatario',
      );

      await tester.pumpWidget(buildPerfilWidget());
      await tester.pumpAndSettle();

      final deleteOptionFinder = find.byKey(const Key('delete_account_button_perfil'));
      await tester.scrollUntilVisible(deleteOptionFinder, 200);
      expect(deleteOptionFinder, findsOneWidget);
      expect(find.text('Eliminar cuenta'), findsOneWidget);

      await tester.tap(deleteOptionFinder);
      await tester.pumpAndSettle();

      expect(find.text('Eliminar cuenta'), findsAtLeast(1));
      expect(find.textContaining('¿Estás seguro? Esta acción eliminará permanentemente tu cuenta'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Eliminar definitivamente'), findsOneWidget);
    });

    testWidgets('Al presionar Cancelar en PerfilPage se cierra el diálogo sin invocar deleteAccount [CL-52]', (tester) async {
      fakeAuthProvider.user = const User(
        id: 'usr-1',
        email: 'tenant@vihome.app',
        role: 'arrendatario',
      );

      await tester.pumpWidget(buildPerfilWidget());
      await tester.pumpAndSettle();

      final deleteOptionFinder = find.byKey(const Key('delete_account_button_perfil'));
      await tester.scrollUntilVisible(deleteOptionFinder, 200);
      await tester.tap(deleteOptionFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.textContaining('¿Estás seguro? Esta acción eliminará permanentemente tu cuenta'), findsNothing);
      expect(fakeAuthProvider.deleteAccountCalled, isFalse);
    });

    testWidgets('Al confirmar en PerfilPage se invoca deleteAccount y redirige a login [CA-3, CA-4]', (tester) async {
      fakeAuthProvider.user = const User(
        id: 'usr-1',
        email: 'tenant@vihome.app',
        role: 'arrendatario',
      );

      await tester.pumpWidget(buildPerfilWidget());
      await tester.pumpAndSettle();

      final deleteOptionFinder = find.byKey(const Key('delete_account_button_perfil'));
      await tester.scrollUntilVisible(deleteOptionFinder, 200);
      await tester.tap(deleteOptionFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Eliminar definitivamente'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(fakeAuthProvider.deleteAccountCalled, isTrue);
      expect(find.text('Login Screen'), findsOneWidget);
    });
  });

  group('Flujo de Eliminación de Cuenta en PanelPage (Arrendador) [RF-53, RF-54, CA-1, CA-2, CA-4, CL-52]', () {
    testWidgets('Muestra la opción "Eliminar cuenta" en PanelPage y abre el diálogo modal [CA-1, CA-2]', (tester) async {
      fakeAuthProvider.user = const User(
        id: 'usr-landlord',
        email: 'landlord@vihome.app',
        role: 'arrendador',
      );

      await tester.pumpWidget(buildPanelWidget());
      await tester.pumpAndSettle();

      final deleteOptionFinder = find.byKey(const Key('delete_account_button_panel'));
      await tester.scrollUntilVisible(deleteOptionFinder, 200);
      expect(deleteOptionFinder, findsOneWidget);

      await tester.tap(deleteOptionFinder);
      await tester.pumpAndSettle();

      expect(find.text('Eliminar cuenta'), findsAtLeast(1));
      expect(find.textContaining('¿Estás seguro? Esta acción eliminará permanentemente tu cuenta'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Eliminar definitivamente'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(fakeAuthProvider.deleteAccountCalled, isFalse);
    });

    testWidgets('Al confirmar en PanelPage se invoca deleteAccount y redirige a login [CA-3, CA-4]', (tester) async {
      fakeAuthProvider.user = const User(
        id: 'usr-landlord',
        email: 'landlord@vihome.app',
        role: 'arrendador',
      );

      await tester.pumpWidget(buildPanelWidget());
      await tester.pumpAndSettle();

      final deleteOptionFinder = find.byKey(const Key('delete_account_button_panel'));
      await tester.scrollUntilVisible(deleteOptionFinder, 200);
      await tester.tap(deleteOptionFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Eliminar definitivamente'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(fakeAuthProvider.deleteAccountCalled, isTrue);
      expect(find.text('Login Screen'), findsOneWidget);
    });
  });
}
