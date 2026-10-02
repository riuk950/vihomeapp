import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/domain/entities/review.dart';
import 'package:vihomeapp/domain/entities/tenant.dart';
import 'package:vihomeapp/domain/entities/user.dart';
import 'package:vihomeapp/domain/entities/user_reputation.dart';
import 'package:vihomeapp/domain/repositories/review_repository.dart';
import 'package:vihomeapp/presentation/pages/navegation/perfil_page.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/presentation/providers/landlord_provider.dart';
import 'package:vihomeapp/presentation/providers/review_provider.dart';
import 'package:vihomeapp/presentation/providers/tenant_provider.dart';
import 'package:vihomeapp/presentation/widgets/review_list_item.dart';
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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockTenantProvider extends ChangeNotifier implements TenantProvider {
  bool _isVerified = false;

  @override
  bool get isVerified => _isVerified;
  set isVerified(bool val) {
    _isVerified = val;
    notifyListeners();
  }

  @override
  bool get isLoading => false;

  @override
  Tenant? get tenant => null;

  @override
  Future<void> loadTenantProfile(String userId) async {}

  @override
  void clearError() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockLandlordProvider extends ChangeNotifier implements LandlordProvider {
  bool _isVerified = false;

  @override
  bool get isVerified => _isVerified;
  set isVerified(bool val) {
    _isVerified = val;
    notifyListeners();
  }

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
  late MockTenantProvider tenantProvider;
  late MockLandlordProvider landlordProvider;

  final testUser = User(
    id: 'user-perfil-1',
    email: 'carlos@vihome.test',
    role: 'arrendatario',
  );

  setUp(() {
    mockReviewRepo = MockReviewRepo();
    reviewProvider = ReviewProvider(mockReviewRepo);
    authProvider = MockAuthProvider();
    tenantProvider = MockTenantProvider();
    landlordProvider = MockLandlordProvider();

    authProvider.user = testUser;
  });

  Widget buildTestableWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<ReviewProvider>.value(value: reviewProvider),
        ChangeNotifierProvider<TenantProvider>.value(value: tenantProvider),
        ChangeNotifierProvider<LandlordProvider>.value(value: landlordProvider),
      ],
      child: const MaterialApp(
        home: PerfilPage(),
      ),
    );
  }

  testWidgets(
      'Muestra UserReputationHeader y lista de opiniones con datos establecidos',
      (WidgetTester tester) async {
    // Configurar reputación y opiniones
    mockReviewRepo.reputations[testUser.id] = UserReputation(
      userId: testUser.id,
      averageRating: 4.8,
      totalReviews: 2,
      isVerified: true,
      userName: testUser.email,
    );
    mockReviewRepo.reviews[testUser.id] = [
      Review(
        id: 'rev-1',
        solicitudId: 'sol-1',
        reviewerId: 'reviewer-1',
        reviewerName: 'Ana María',
        targetUserId: testUser.id,
        rating: 5,
        comment: 'Excelente arrendatario, muy puntual y cuidadoso con el inmueble.',
        createdAt: DateTime(2025, 2, 10),
      ),
      Review(
        id: 'rev-2',
        solicitudId: 'sol-2',
        reviewerId: 'reviewer-2',
        reviewerName: 'Pedro Gómez',
        targetUserId: testUser.id,
        rating: 4,
        comment: 'Todo en orden durante el contrato.',
        createdAt: DateTime(2025, 1, 15),
      ),
    ];

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Validar encabezado de reputación
    expect(find.byType(UserReputationHeader), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);
    expect(find.text('Basado en 2 reseñas'), findsOneWidget);

    // Validar título y contador de la sección de opiniones
    expect(find.text('Mis Opiniones Recibidas'), findsOneWidget);
    expect(find.text('2 opiniones'), findsOneWidget);

    // Validar que se muestren las opiniones mediante ReviewListItem
    expect(find.byType(ReviewListItem), findsNWidgets(2));
    expect(find.text('Ana María'), findsOneWidget);
    expect(find.text('Excelente arrendatario, muy puntual y cuidadoso con el inmueble.'), findsOneWidget);
    expect(find.text('Pedro Gómez'), findsOneWidget);
    expect(find.text('Todo en orden durante el contrato.'), findsOneWidget);
  });

  testWidgets(
      'Muestra estado neutral y mensaje vacío cuando el usuario no tiene calificaciones',
      (WidgetTester tester) async {
    mockReviewRepo.reputations[testUser.id] = UserReputation(
      userId: testUser.id,
      averageRating: null,
      totalReviews: 0,
      isVerified: false,
    );
    mockReviewRepo.reviews[testUser.id] = [];

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Validar encabezado neutral
    expect(find.byType(UserReputationHeader), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('Sin calificaciones aún'), findsOneWidget);

    // Validar mensaje vacío en lista
    expect(find.text('0 opiniones'), findsOneWidget);
    expect(find.text('Aún no se han recibido opiniones.'), findsOneWidget);
    expect(find.byType(ReviewListItem), findsNothing);
  });

  testWidgets(
      'Muestra calificación provisional 3.0 para usuario verificado sin historial',
      (WidgetTester tester) async {
    tenantProvider.isVerified = true;
    mockReviewRepo.reputations[testUser.id] = UserReputation(
      userId: testUser.id,
      averageRating: null,
      totalReviews: 0,
      isVerified: true,
    );
    mockReviewRepo.reviews[testUser.id] = [];

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Validar encabezado provisional
    expect(find.byType(UserReputationHeader), findsOneWidget);
    expect(find.text('3.0'), findsOneWidget);
    expect(find.text('Puntaje inicial de confianza'), findsOneWidget);
    expect(find.text('Usuario verificado con nivel inicial de confianza'), findsOneWidget);
    expect(find.byIcon(Icons.verified), findsOneWidget);
  });

  testWidgets(
      'RefreshIndicator refresca reputación y opiniones al deslizar hacia abajo',
      (WidgetTester tester) async {
    mockReviewRepo.reputations[testUser.id] = UserReputation(
      userId: testUser.id,
      averageRating: null,
      totalReviews: 0,
      isVerified: false,
    );
    mockReviewRepo.reviews[testUser.id] = [];

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final initialReputationCalls = mockReviewRepo.fetchReputationCalls;
    final initialReviewsCalls = mockReviewRepo.fetchReviewsCalls;

    // Ejecutar pull-to-refresh
    await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verificar que se invocaron nuevamente los métodos de carga
    expect(mockReviewRepo.fetchReputationCalls, greaterThan(initialReputationCalls));
    expect(mockReviewRepo.fetchReviewsCalls, greaterThan(initialReviewsCalls));
  });
}
