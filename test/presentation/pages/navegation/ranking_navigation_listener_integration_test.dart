import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/core/ads/ad_manager.dart';
import 'package:vihomeapp/core/di/injection_container.dart';
import 'package:vihomeapp/core/router/app_router.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/entities/landlord.dart';
import 'package:vihomeapp/domain/entities/tenant.dart';
import 'package:vihomeapp/domain/entities/project.dart';
import 'package:vihomeapp/domain/entities/property.dart';
import 'package:vihomeapp/domain/entities/property_type.dart';
import 'package:vihomeapp/domain/entities/review.dart';
import 'package:vihomeapp/domain/entities/user.dart';
import 'package:vihomeapp/domain/entities/user_reputation.dart';
import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/domain/repositories/landlord_repository.dart';
import 'package:vihomeapp/domain/repositories/review_repository.dart';
import 'package:vihomeapp/domain/usecases/landlord/get_landlord_profile_usecase.dart';
import 'package:vihomeapp/data/models/property_model.dart';
import '../../../fixtures/fixtures.dart';
import 'package:vihomeapp/presentation/pages/navegation/home_page.dart';
import 'package:vihomeapp/presentation/pages/navegation/panel_page.dart';
import 'package:vihomeapp/presentation/pages/navegation/perfil_page.dart';
import 'package:vihomeapp/presentation/pages/propiedades/detalles_propiedades_page.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/presentation/providers/landlord_properties_provider.dart';
import 'package:vihomeapp/presentation/providers/landlord_provider.dart';
import 'package:vihomeapp/presentation/providers/project_provider.dart';
import 'package:vihomeapp/presentation/providers/property_provider.dart';
import 'package:vihomeapp/presentation/providers/review_provider.dart';
import 'package:vihomeapp/presentation/providers/tenant_provider.dart';

class MockReviewRepo implements ReviewRepository {
  final Map<String, UserReputation> reputations = {};
  final Map<String, List<Review>> reviews = {};
  int fetchReputationCalls = 0;
  int fetchReviewsCalls = 0;

  @override
  Future<Review> createReview({
    required String solicitudId,
    required String reviewerId,
    required String targetUserId,
    required int rating,
    String? comment,
    String? reviewerName,
  }) async {
    final newReview = Review(
      id: 'new-rev',
      solicitudId: solicitudId,
      reviewerId: reviewerId,
      targetUserId: targetUserId,
      rating: rating,
      comment: comment,
      reviewerName: reviewerName,
      createdAt: DateTime.now(),
    );
    final current = reviews[targetUserId] ?? [];
    reviews[targetUserId] = [newReview, ...current];
    return newReview;
  }

  @override
  Future<UserReputation> getUserReputation(
    String userId, {
    bool isVerified = false,
    String? userName,
  }) async {
    fetchReputationCalls++;
    return reputations[userId] ??
        UserReputation(
          userId: userId,
          userName: userName,
          isVerified: isVerified,
        );
  }

  @override
  Future<List<Review>> getUserReviews(String userId) async {
    fetchReviewsCalls++;
    return reviews[userId] ?? [];
  }

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
      Review(
        id: 'rev-verified',
        solicitudId: null,
        reviewerId: userId,
        reviewerName: userName,
        targetUserId: userId,
        rating: 3,
        comment: 'Usuario verificado',
        createdAt: DateTime.now(),
      );
}

class MockLandlordRepo implements LandlordRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Either<Failure, Landlord>> getLandlordProfile(String userId) async {
    return const Right(
      Landlord(
        id: 'usr-nav-landlord-1',
        primerNombre: 'Don Carlos',
        primerApellido: 'Gómez',
        documento: '12345678',
        direccionContacto: 'Calle 10 # 5-20',
        tipoDocumento: 'CC',
        telefonoContacto: '3001234567',
      ),
    );
  }
}

class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  User? _user;

  @override
  User? get user => _user;
  set user(User? u) {
    _user = u;
    notifyListeners();
  }

  @override
  Future<void> reloadUser() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockLandlordProvider extends ChangeNotifier implements LandlordProvider {
  bool _isVerified = true;
  Landlord? _landlord;

  @override
  bool get isVerified => _isVerified;
  set isVerified(bool v) {
    _isVerified = v;
    notifyListeners();
  }

  @override
  bool get isLoading => false;

  @override
  Landlord? get landlord => _landlord;

  @override
  Future<void> loadLandlordProfile(String userId) async {}

  @override
  void clear() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockTenantProvider extends ChangeNotifier implements TenantProvider {
  @override
  bool get isVerified => true;

  @override
  bool get isLoading => false;

  @override
  Tenant? get tenant => null;

  @override
  Future<void> loadTenantProfile(String userId) async {}

  @override
  void clear() {}

  @override
  void clearError() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockApplicationProvider extends ChangeNotifier
    implements ApplicationProvider {
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
  Future<bool> hasApplicationForProperty(
          String userId, String propertyId) async =>
      false;

  @override
  int get unreadLandlordCount => 0;

  @override
  int get unreadTenantCount => 0;

  @override
  void clear() {}

  @override
  void clearError() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockPropertyProvider extends ChangeNotifier implements PropertyProvider {
  @override
  List<Property> get properties => [];

  @override
  List<PropertyType> get propertyTypes => [];

  @override
  PropertyType? get selectedType => null;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  Future<void> fetchProperties() async {}

  @override
  Future<void> fetchPropertyTypes() async {}

  @override
  void clearError() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockLandlordPropertiesProvider extends ChangeNotifier
    implements LandlordPropertiesProvider {
  @override
  List<Property> get properties => [];

  @override
  bool get isLoading => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockProjectProvider extends ChangeNotifier implements ProjectProvider {
  @override
  List<Project> get projects => [];

  @override
  List<Project> get filteredProjects => [];

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  String? get selectedFilter => null;

  @override
  Future<void> fetchProjects() async {}

  @override
  void clearError() {}

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

  late MockReviewRepo mockReviewRepo;
  late ReviewProvider reviewProvider;
  late MockAuthProvider authProvider;
  late MockLandlordProvider landlordProvider;
  late MockTenantProvider tenantProvider;
  late MockApplicationProvider appProvider;
  late MockPropertyProvider propertyProvider;
  late MockLandlordPropertiesProvider landlordPropertiesProvider;
  late MockProjectProvider projectProvider;

  final landlordUser = User(
    id: 'usr-nav-landlord-1',
    email: 'landlord@nav.test',
    role: 'arrendador',
    isPremium: true,
  );

  final tenantUser = User(
    id: 'usr-nav-tenant-1',
    email: 'tenant@nav.test',
    role: 'arrendatario',
    isPremium: true,
  );

  setUp(() {
    if (getIt.isRegistered<AdManager>()) getIt.unregister<AdManager>();
    getIt.registerSingleton<AdManager>(AdManager());

    if (getIt.isRegistered<GetLandlordProfileUseCase>()) {
      getIt.unregister<GetLandlordProfileUseCase>();
    }
    getIt.registerLazySingleton<GetLandlordProfileUseCase>(
      () => GetLandlordProfileUseCase(MockLandlordRepo()),
    );

    mockReviewRepo = MockReviewRepo();
    reviewProvider = ReviewProvider(mockReviewRepo);
    authProvider = MockAuthProvider();
    landlordProvider = MockLandlordProvider();
    tenantProvider = MockTenantProvider();
    appProvider = MockApplicationProvider();
    propertyProvider = MockPropertyProvider();
    landlordPropertiesProvider = MockLandlordPropertiesProvider();
    projectProvider = MockProjectProvider();
  });

  tearDown(() {
    if (getIt.isRegistered<AdManager>()) getIt.unregister<AdManager>();
    if (getIt.isRegistered<GetLandlordProfileUseCase>()) {
      getIt.unregister<GetLandlordProfileUseCase>();
    }
  });

  Widget buildTestableApp({required Widget home}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<ReviewProvider>.value(value: reviewProvider),
        ChangeNotifierProvider<LandlordProvider>.value(value: landlordProvider),
        ChangeNotifierProvider<TenantProvider>.value(value: tenantProvider),
        ChangeNotifierProvider<ApplicationProvider>.value(value: appProvider),
        ChangeNotifierProvider<PropertyProvider>.value(value: propertyProvider),
        ChangeNotifierProvider<LandlordPropertiesProvider>.value(
            value: landlordPropertiesProvider),
        ChangeNotifierProvider<ProjectProvider>.value(value: projectProvider),
      ],
      child: MaterialApp(
        navigatorObservers: [appRouteObserver],
        home: home,
      ),
    );
  }

  testWidgets(
      'HomePage al cambiar a pestaña de Panel (Arrendador) sincroniza la reputación [RF-35.2]',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    authProvider.user = landlordUser;

    await tester.pumpWidget(buildTestableApp(home: const HomePage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final initialReputationCalls = mockReviewRepo.fetchReputationCalls;
    final initialReviewsCalls = mockReviewRepo.fetchReviewsCalls;

    // Cambiar a la pestaña de Panel (index 3)
    await tester.tap(find.text('Panel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(mockReviewRepo.fetchReputationCalls,
        greaterThan(initialReputationCalls));
    expect(mockReviewRepo.fetchReviewsCalls,
        greaterThan(initialReviewsCalls));
  });

  testWidgets(
      'HomePage al cambiar a pestaña de Perfil (Arrendatario) sincroniza la reputación [RF-35.1]',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    authProvider.user = tenantUser;

    await tester.pumpWidget(buildTestableApp(home: const HomePage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final initialReputationCalls = mockReviewRepo.fetchReputationCalls;
    final initialReviewsCalls = mockReviewRepo.fetchReviewsCalls;

    // Cambiar a la pestaña de Perfil (index 3)
    await tester.tap(find.text('Perfil'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(mockReviewRepo.fetchReputationCalls,
        greaterThan(initialReputationCalls));
    expect(mockReviewRepo.fetchReviewsCalls,
        greaterThan(initialReviewsCalls));
  });

  testWidgets(
      'PanelPage con RouteAware re-sincroniza reputación al recibir didPopNext [RF-35.2]',
      (WidgetTester tester) async {
    authProvider.user = landlordUser;

    await tester.pumpWidget(buildTestableApp(home: const PanelPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final initialCalls = mockReviewRepo.fetchReputationCalls;

    // Simular retorno de navegación invocando didPopNext a través del State
    final panelState =
        tester.state(find.byType(PanelPage)) as RouteAware;
    panelState.didPopNext();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(mockReviewRepo.fetchReputationCalls, greaterThan(initialCalls));
  });

  testWidgets(
      'PerfilPage con RouteAware re-sincroniza reputación al recibir didPopNext [RF-35.1]',
      (WidgetTester tester) async {
    authProvider.user = tenantUser;

    await tester.pumpWidget(buildTestableApp(home: const PerfilPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final initialCalls = mockReviewRepo.fetchReputationCalls;

    // Simular retorno de navegación invocando didPopNext a través del State
    final perfilState =
        tester.state(find.byType(PerfilPage)) as RouteAware;
    perfilState.didPopNext();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(mockReviewRepo.fetchReputationCalls, greaterThan(initialCalls));
  });

  testWidgets(
      'DetallesPropiedadesPage con RouteAware re-sincroniza reputación del arrendador al recibir didPopNext [RF-35.3]',
      (WidgetTester tester) async {
    authProvider.user = tenantUser;
    final property = PropertyModel.fromJson({
      ...PropertyFixtures.validApartmentBogotaJson,
      'arrendador_id': landlordUser.id,
    });

    await tester.pumpWidget(buildTestableApp(
      home: DetallesPropiedadesPage(
        property: property,
        user: tenantUser,
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final initialCalls = mockReviewRepo.fetchReputationCalls;

    final detallesState =
        tester.state(find.byType(DetallesPropiedadesPage)) as RouteAware;
    detallesState.didPopNext();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(mockReviewRepo.fetchReputationCalls, greaterThan(initialCalls));
  });
}
