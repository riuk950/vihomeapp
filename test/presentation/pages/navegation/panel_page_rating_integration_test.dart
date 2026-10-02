import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/entities/landlord.dart';
import 'package:vihomeapp/domain/entities/review.dart';
import 'package:vihomeapp/domain/entities/user.dart';
import 'package:vihomeapp/domain/entities/user_reputation.dart';
import 'package:vihomeapp/domain/repositories/review_repository.dart';
import 'package:vihomeapp/presentation/pages/navegation/panel_page.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/presentation/providers/landlord_provider.dart';
import 'package:vihomeapp/presentation/providers/review_provider.dart';
import 'package:vihomeapp/presentation/providers/tenant_provider.dart';
import 'package:vihomeapp/presentation/widgets/landlord_reputation_bottom_sheet.dart';
import 'package:vihomeapp/presentation/widgets/user_reputation_header.dart';

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
    throw UnimplementedError();
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
  Future<void> signOut() async {
    _user = null;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockLandlordProvider extends ChangeNotifier implements LandlordProvider {
  bool _isVerified = false;
  Landlord? _landlord;

  @override
  bool get isVerified => _isVerified;
  set isVerified(bool val) {
    _isVerified = val;
    notifyListeners();
  }

  @override
  bool get isLoading => false;

  @override
  Landlord? get landlord => _landlord;
  set landlord(Landlord? l) {
    _landlord = l;
    notifyListeners();
  }

  @override
  Future<void> loadLandlordProfile(String userId) async {}

  @override
  void clear() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockApplicationProvider extends ChangeNotifier
    implements ApplicationProvider {
  List<Application> _applications = [];

  @override
  List<Application> get applications => _applications;
  set applications(List<Application> apps) {
    _applications = apps;
    notifyListeners();
  }

  @override
  bool get isLoading => false;

  @override
  Future<void> fetchLandlordApplications(String landlordId,
      {bool silent = false}) async {}

  @override
  Future<void> fetchTenantApplications(String tenantId,
      {bool silent = false}) async {}

  @override
  void clear() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockTenantProvider extends ChangeNotifier implements TenantProvider {
  @override
  bool get isVerified => false;

  @override
  bool get isLoading => false;

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

  late MockReviewRepo mockReviewRepo;
  late ReviewProvider reviewProvider;
  late MockAuthProvider authProvider;
  late MockLandlordProvider landlordProvider;
  late MockApplicationProvider appProvider;
  late MockTenantProvider tenantProvider;

  final landlordUser = User(
    id: 'usr-landlord-1',
    email: 'roberto@landlord.test',
    role: 'arrendador',
  );

  final tenantUser = User(
    id: 'usr-tenant-1',
    email: 'carlos@tenant.test',
    role: 'arrendatario',
  );

  setUp(() {
    mockReviewRepo = MockReviewRepo();
    reviewProvider = ReviewProvider(mockReviewRepo);
    authProvider = MockAuthProvider();
    landlordProvider = MockLandlordProvider();
    appProvider = MockApplicationProvider();
    tenantProvider = MockTenantProvider();

    authProvider.user = landlordUser;
    landlordProvider.isVerified = true;
    landlordProvider.landlord = const Landlord(
      id: 'landlord-detail-1',
      primerNombre: 'Roberto',
      primerApellido: 'Gómez',
      documento: '12345678',
      direccionContacto: 'Calle 10 # 5-20',
      tipoDocumento: 'CC',
      telefonoContacto: '3001234567',
    );
  });

  Widget buildTestableWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<LandlordProvider>.value(value: landlordProvider),
        ChangeNotifierProvider<ApplicationProvider>.value(value: appProvider),
        ChangeNotifierProvider<ReviewProvider>.value(value: reviewProvider),
        ChangeNotifierProvider<TenantProvider>.value(value: tenantProvider),
      ],
      child: const MaterialApp(
        home: PanelPage(),
      ),
    );
  }

  testWidgets(
      'Muestra tarjeta de reputación del arrendador con datos establecidos (4.8 y 2 opiniones)',
      (WidgetTester tester) async {
    mockReviewRepo.reputations[landlordUser.id] = UserReputation(
      userId: landlordUser.id,
      averageRating: 4.8,
      totalReviews: 2,
      isVerified: true,
      userName: landlordUser.email,
    );
    mockReviewRepo.reviews[landlordUser.id] = [
      Review(
        id: 'rev-1',
        solicitudId: 'sol-1',
        reviewerId: 'rev-user-1',
        reviewerName: 'Ana María',
        targetUserId: landlordUser.id,
        rating: 5,
        comment: 'Excelente arrendador, muy atento y responsable.',
        createdAt: DateTime(2025, 2, 10),
      ),
      Review(
        id: 'rev-2',
        solicitudId: 'sol-2',
        reviewerId: 'rev-user-2',
        reviewerName: 'Pedro Pérez',
        targetUserId: landlordUser.id,
        rating: 4,
        comment: 'Buena comunicación.',
        createdAt: DateTime(2025, 1, 15),
      ),
    ];

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Validar encabezado y resumen
    expect(find.text('Mi Reputación como Arrendador'), findsOneWidget);
    expect(find.text('2 opiniones'), findsOneWidget);
    expect(find.byType(UserReputationHeader), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);
    expect(find.text('Basado en 2 reseñas'), findsOneWidget);
  });

  testWidgets(
      'Al tocar la tarjeta de reputación se abre LandlordReputationBottomSheet con las opiniones',
      (WidgetTester tester) async {
    mockReviewRepo.reputations[landlordUser.id] = UserReputation(
      userId: landlordUser.id,
      averageRating: 4.8,
      totalReviews: 2,
      isVerified: true,
      userName: landlordUser.email,
    );
    mockReviewRepo.reviews[landlordUser.id] = [
      Review(
        id: 'rev-1',
        solicitudId: 'sol-1',
        reviewerId: 'rev-user-1',
        reviewerName: 'Ana María',
        targetUserId: landlordUser.id,
        rating: 5,
        comment: 'Excelente arrendador, muy atento y responsable.',
        createdAt: DateTime(2025, 2, 10),
      ),
    ];

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tocar la sección de reputación
    await tester.tap(find.text('Mi Reputación como Arrendador'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verificar que se abrió el BottomSheet con la información del arrendador
    expect(find.byType(LandlordReputationBottomSheet), findsOneWidget);
    expect(find.text('Roberto Gómez'), findsOneWidget);
    expect(find.text('Excelente arrendador, muy atento y responsable.'),
        findsOneWidget);
  });

  testWidgets(
      'Muestra puntaje inicial de confianza (3.0) para arrendador verificado sin reseñas',
      (WidgetTester tester) async {
    mockReviewRepo.reputations[landlordUser.id] = UserReputation(
      userId: landlordUser.id,
      averageRating: 3.0,
      totalReviews: 0,
      isVerified: true,
      userName: landlordUser.email,
    );
    mockReviewRepo.reviews[landlordUser.id] = [];

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Mi Reputación como Arrendador'), findsOneWidget);
    expect(find.text('0 opiniones'), findsOneWidget);
    expect(find.byType(UserReputationHeader), findsOneWidget);
    expect(find.text('3.0'), findsOneWidget);
    expect(find.text('Puntaje inicial de confianza'), findsOneWidget);
  });

  testWidgets(
      'Muestra estado neutral (— y Sin calificaciones aún) para arrendador no verificado sin reseñas',
      (WidgetTester tester) async {
    landlordProvider.isVerified = false;
    mockReviewRepo.reputations[landlordUser.id] = UserReputation(
      userId: landlordUser.id,
      averageRating: null,
      totalReviews: 0,
      isVerified: false,
      userName: landlordUser.email,
    );
    mockReviewRepo.reviews[landlordUser.id] = [];

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Mi Reputación como Arrendador'), findsOneWidget);
    expect(find.text('0 opiniones'), findsOneWidget);
    expect(find.byType(UserReputationHeader), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('Sin calificaciones aún'), findsOneWidget);
  });

  testWidgets(
      'RefreshIndicator refresca la reputación del arrendador al deslizar hacia abajo',
      (WidgetTester tester) async {
    mockReviewRepo.reputations[landlordUser.id] = UserReputation(
      userId: landlordUser.id,
      averageRating: 4.5,
      totalReviews: 1,
      isVerified: true,
      userName: landlordUser.email,
    );
    mockReviewRepo.reviews[landlordUser.id] = [];

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final initialReputationCalls = mockReviewRepo.fetchReputationCalls;
    final initialReviewsCalls = mockReviewRepo.fetchReviewsCalls;

    // Ejecutar pull-to-refresh
    await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(mockReviewRepo.fetchReputationCalls,
        greaterThan(initialReputationCalls));
    expect(mockReviewRepo.fetchReviewsCalls,
        greaterThan(initialReviewsCalls));
  });

  testWidgets(
      'No muestra tarjeta de reputación del arrendador cuando el usuario tiene rol de arrendatario',
      (WidgetTester tester) async {
    authProvider.user = tenantUser;

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Mi Reputación como Arrendador'), findsNothing);
    expect(find.byType(UserReputationHeader), findsNothing);
  });
}
