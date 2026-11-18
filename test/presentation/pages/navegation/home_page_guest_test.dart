import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/core/ads/ad_manager.dart';
import 'package:vihomeapp/core/di/injection_container.dart';
import 'package:vihomeapp/core/router/guest_access_guard.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/entities/guest_redirect_context.dart';
import 'package:vihomeapp/domain/entities/landlord.dart';
import 'package:vihomeapp/domain/entities/project.dart';
import 'package:vihomeapp/domain/entities/property.dart';
import 'package:vihomeapp/domain/entities/property_type.dart';
import 'package:vihomeapp/domain/entities/review.dart';
import 'package:vihomeapp/domain/entities/tenant.dart';
import 'package:vihomeapp/domain/entities/user.dart';
import 'package:vihomeapp/domain/entities/user_reputation.dart';
import 'package:vihomeapp/domain/repositories/review_repository.dart';
import 'package:vihomeapp/presentation/pages/navegation/home_page.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/presentation/providers/landlord_properties_provider.dart';
import 'package:vihomeapp/presentation/providers/landlord_provider.dart';
import 'package:vihomeapp/presentation/providers/project_provider.dart';
import 'package:vihomeapp/presentation/providers/property_provider.dart';
import 'package:vihomeapp/presentation/providers/review_provider.dart';
import 'package:vihomeapp/presentation/providers/subscription_provider.dart';
import 'package:vihomeapp/presentation/providers/tenant_provider.dart';

class _HomeFakeAuthProvider extends ChangeNotifier implements AuthProvider {
  User? _user;
  _HomeFakeAuthProvider({User? user}) : _user = user;

  @override
  User? get user => _user;

  void setUser(User? newUser) {
    _user = newUser;
    notifyListeners();
  }

  @override
  bool get isAuthenticated => _user != null;

  @override
  bool get isGuest => !isAuthenticated;

  @override
  bool get isLoading => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePropertyProvider extends ChangeNotifier implements PropertyProvider {
  String? _error;
  final List<Property> _properties = [];

  set errorMessageForTest(String? value) {
    _error = value;
    notifyListeners();
  }

  @override
  List<Property> get properties => _properties;

  @override
  List<PropertyType> get propertyTypes => const [];

  @override
  PropertyType? get selectedType => null;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => _error;

  @override
  Future<void> fetchProperties() async {}

  @override
  Future<void> fetchPropertyTypes() async {}

  @override
  void selectType(PropertyType? type) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLandlordPropertiesProvider extends ChangeNotifier
    implements LandlordPropertiesProvider {
  @override
  List<Property> get properties => [];

  @override
  bool get isLoading => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProjectProvider extends ChangeNotifier implements ProjectProvider {
  @override
  List<Project> get projects => [];

  @override
  List<Project> get filteredProjects => [];

  @override
  String? get selectedFilter => null;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  Future<void> fetchProjects() async {}

  @override
  void selectFilter(String? filter) {}

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
  int get unreadLandlordCount => 2;

  @override
  int get unreadTenantCount => 1;

  @override
  Future<void> fetchLandlordApplications(String landlordId,
      {bool silent = false}) async {}

  @override
  Future<void> fetchTenantApplications(String tenantId,
      {bool silent = false}) async {}

  @override
  void clear() {
    cleared = true;
  }

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
  void clear() {
    cleared = true;
  }

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
  void clear() {
    cleared = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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

class _FakeSubscriptionProvider extends SubscriptionProvider {
  bool cleared = false;

  @override
  void clear() {
    cleared = true;
    super.clear();
  }
}

class _FakeAdManager implements AdManager {
  @override
  String get bannerAdUnitId => '';

  @override
  void showInterstitialAd({required bool isPremium}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() async {
    GuestAccessGuard.resetForTesting();
    await getIt.reset();
    getIt.registerLazySingleton<AdManager>(() => _FakeAdManager());
  });

  tearDown(() async {
    GuestAccessGuard.resetForTesting();
    await getIt.reset();
  });

  group('HomePage - Navegación del Rol Invitado (RF-2, RF-3, RF-6.2, RF-7.3, RF-8.1)', () {
    testWidgets('Permite navegar Arriendos, Ventas y Proyectos con notificaciones ocultas y redirige a /login al tocar Perfil preservando la pestaña previa', (tester) async {
      final authProvider = _HomeFakeAuthProvider(user: null);
      final propertyProvider = _FakePropertyProvider();
      final landlordPropsProvider = _FakeLandlordPropertiesProvider();
      final projectProvider = _FakeProjectProvider();
      final appProvider = _FakeApplicationProvider();
      final tenantProvider = _FakeTenantProvider();
      final landlordProvider = _FakeLandlordProvider();
      final subscriptionProvider = _FakeSubscriptionProvider();

      GuestRedirectContext? lastRedirect;

      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) {
              lastRedirect = state.extra as GuestRedirectContext?;
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    GuestAccessGuard.resetDebounce();
                    context.pop();
                  },
                  child: const Text('RETURN_GUEST'),
                ),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<PropertyProvider>.value(value: propertyProvider),
            ChangeNotifierProvider<LandlordPropertiesProvider>.value(
                value: landlordPropsProvider),
            ChangeNotifierProvider<ProjectProvider>.value(value: projectProvider),
            ChangeNotifierProvider<ApplicationProvider>.value(value: appProvider),
            ChangeNotifierProvider<TenantProvider>.value(value: tenantProvider),
            ChangeNotifierProvider<LandlordProvider>.value(value: landlordProvider),
            ChangeNotifierProvider<SubscriptionProvider>.value(
                value: subscriptionProvider),
            ChangeNotifierProvider<ReviewProvider>(
              create: (_) => ReviewProvider(_MockReviewRepo()),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Ícono de notificaciones oculto en modo invitado (RF-2.4)
      expect(find.byIcon(Icons.notifications_none), findsNothing);

      // Navegar a Ventas y Proyectos sin errores (RF-2.1)
      await tester.tap(find.text('Ventas'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.notifications_none), findsNothing);

      await tester.tap(find.text('Proyectos'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.notifications_none), findsNothing);

      // Pulsar Perfil como invitado -> redirige a /login con motivo profile (RF-3.1, RF-3.2)
      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();

      expect(find.text('RETURN_GUEST'), findsOneWidget);
      expect(lastRedirect?.reason, GuestRedirectReason.profile);
      expect(lastRedirect?.showRestrictionBanner, isTrue);

      // Regresar como invitado conserva la pestaña Proyectos (RF-3.3, RF-6.2)
      await tester.tap(find.text('RETURN_GUEST'));
      await tester.pumpAndSettle();

      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar.currentIndex, 2);
    });

    testWidgets('Transición de arrendador a invitado revierte Panel a Perfil y limpia providers privados (RF-7.3)', (tester) async {
      final authProvider = _HomeFakeAuthProvider(
        user: const User(id: 'u-landlord', email: 'l@v.com', role: 'arrendador'),
      );
      final propertyProvider = _FakePropertyProvider();
      final landlordPropsProvider = _FakeLandlordPropertiesProvider();
      final projectProvider = _FakeProjectProvider();
      final appProvider = _FakeApplicationProvider();
      final tenantProvider = _FakeTenantProvider();
      final landlordProvider = _FakeLandlordProvider();
      final subscriptionProvider = _FakeSubscriptionProvider();

      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<PropertyProvider>.value(value: propertyProvider),
            ChangeNotifierProvider<LandlordPropertiesProvider>.value(
                value: landlordPropsProvider),
            ChangeNotifierProvider<ProjectProvider>.value(value: projectProvider),
            ChangeNotifierProvider<ApplicationProvider>.value(value: appProvider),
            ChangeNotifierProvider<TenantProvider>.value(value: tenantProvider),
            ChangeNotifierProvider<LandlordProvider>.value(value: landlordProvider),
            ChangeNotifierProvider<SubscriptionProvider>.value(
                value: subscriptionProvider),
            ChangeNotifierProvider<ReviewProvider>(
              create: (_) => ReviewProvider(_MockReviewRepo()),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Como arrendador autenticado muestra "Panel" y las notificaciones
      expect(find.text('Panel'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none), findsWidgets);

      // Simular cierre de sesión / paso a invitado
      authProvider.setUser(null);
      await tester.pumpAndSettle();

      expect(find.text('Perfil'), findsOneWidget);
      expect(find.text('Panel'), findsNothing);
      expect(find.byIcon(Icons.notifications_none), findsNothing);
      expect(appProvider.cleared, isTrue);
      expect(tenantProvider.cleared, isTrue);
      expect(landlordProvider.cleared, isTrue);
      expect(subscriptionProvider.cleared, isTrue);
    });

    testWidgets('Error de red al cargar listados como invitado muestra reintentar y nunca redirige a /login (RF-8.1)', (tester) async {
      final authProvider = _HomeFakeAuthProvider(user: null);
      final propertyProvider = _FakePropertyProvider()
        ..errorMessageForTest = 'Sin conexión a internet';
      final landlordPropsProvider = _FakeLandlordPropertiesProvider();
      final projectProvider = _FakeProjectProvider();
      final appProvider = _FakeApplicationProvider();
      final tenantProvider = _FakeTenantProvider();
      final landlordProvider = _FakeLandlordProvider();
      final subscriptionProvider = _FakeSubscriptionProvider();

      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => const Scaffold(body: Text('LOGIN_SCREEN')),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<PropertyProvider>.value(value: propertyProvider),
            ChangeNotifierProvider<LandlordPropertiesProvider>.value(
                value: landlordPropsProvider),
            ChangeNotifierProvider<ProjectProvider>.value(value: projectProvider),
            ChangeNotifierProvider<ApplicationProvider>.value(value: appProvider),
            ChangeNotifierProvider<TenantProvider>.value(value: tenantProvider),
            ChangeNotifierProvider<LandlordProvider>.value(value: landlordProvider),
            ChangeNotifierProvider<SubscriptionProvider>.value(
                value: subscriptionProvider),
            ChangeNotifierProvider<ReviewProvider>(
              create: (_) => ReviewProvider(_MockReviewRepo()),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('LOGIN_SCREEN'), findsNothing);
      expect(find.text('Reintentar'), findsOneWidget);
    });
  });
}
