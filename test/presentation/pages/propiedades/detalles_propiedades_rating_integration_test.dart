import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/core/ads/ad_manager.dart';
import 'package:vihomeapp/core/di/injection_container.dart';
import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/data/models/property_model.dart';
import 'package:vihomeapp/domain/entities/landlord.dart';
import 'package:vihomeapp/domain/entities/property.dart';
import 'package:vihomeapp/domain/entities/review.dart';
import 'package:vihomeapp/domain/entities/user.dart';
import 'package:vihomeapp/domain/entities/user_reputation.dart';
import 'package:vihomeapp/domain/repositories/landlord_repository.dart';
import 'package:vihomeapp/domain/repositories/review_repository.dart';
import 'package:vihomeapp/domain/usecases/landlord/get_landlord_profile_usecase.dart';
import 'package:vihomeapp/presentation/pages/propiedades/detalles_propiedades_page.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/presentation/providers/review_provider.dart';
import 'package:vihomeapp/presentation/providers/tenant_provider.dart';
import '../../../fixtures/fixtures.dart';

class MockReviewRepo implements ReviewRepository {
  final Map<String, UserReputation> reputations = {};
  final Map<String, List<Review>> reviews = {};

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
  Future<UserReputation> getUserReputation(String userId,
      {bool isVerified = false, String? userName}) async {
    return reputations[userId] ??
        UserReputation(
          userId: userId,
          averageRating: 4.8,
          totalReviews: 12,
          isVerified: isVerified,
        );
  }

  @override
  Future<List<Review>> getUserReviews(String userId) async {
    return reviews[userId] ?? [];
  }

  @override
  Future<bool> canUserRateApplication(
          {required String solicitudId, required String userId}) async =>
      false;

  @override
  Future<Review> registerVerifiedUserReview(
          {required String userId, String? userName}) async =>
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
        id: 'landlord-doc-1',
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
  void setUser(User? u) {
    _user = u;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockTenantProvider extends ChangeNotifier implements TenantProvider {
  @override
  void clearError() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockApplicationProvider extends ChangeNotifier implements ApplicationProvider {
  @override
  void clearError() {}

  @override
  Future<bool> hasApplicationForProperty(String tenantId, String propertyId) async => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    dotenv.testLoad(
      fileInput: 'DEBUG_MODE=true\nMAPBOX_ACCESS_TOKEN=\nADMOB_BANNER_ID=\nAPI_BASE_URL=https://example.com',
    );
  });

  late MockReviewRepo mockReviewRepo;
  late ReviewProvider reviewProvider;
  late MockAuthProvider authProvider;
  late MockTenantProvider tenantProvider;
  late MockApplicationProvider appProvider;

  final testUser = User(
    id: 'usr-tenant-1',
    email: 'tenant@test.com',
    role: 'arrendatario',
    isPremium: false,
  );

  final testProperty = PropertyModel.fromJson(PropertyFixtures.validApartmentBogotaJson);

  setUp(() {
    if (getIt.isRegistered<AdManager>()) getIt.unregister<AdManager>();
    if (getIt.isRegistered<GetLandlordProfileUseCase>()) {
      getIt.unregister<GetLandlordProfileUseCase>();
    }

    getIt.registerSingleton<AdManager>(AdManager());
    getIt.registerSingleton<GetLandlordProfileUseCase>(
      GetLandlordProfileUseCase(MockLandlordRepo()),
    );

    mockReviewRepo = MockReviewRepo();
    reviewProvider = ReviewProvider(mockReviewRepo);

    authProvider = MockAuthProvider()..setUser(testUser);
    tenantProvider = MockTenantProvider();
    appProvider = MockApplicationProvider();
  });

  tearDown(() {
    if (getIt.isRegistered<AdManager>()) getIt.unregister<AdManager>();
    if (getIt.isRegistered<GetLandlordProfileUseCase>()) {
      getIt.unregister<GetLandlordProfileUseCase>();
    }
  });

  Widget buildTestScreen({Property? property}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<ReviewProvider>.value(value: reviewProvider),
        ChangeNotifierProvider<TenantProvider>.value(value: tenantProvider),
        ChangeNotifierProvider<ApplicationProvider>.value(value: appProvider),
      ],
      child: MaterialApp(
        home: DetallesPropiedadesPage(
          property: property ?? testProperty,
          user: testUser,
        ),
      ),
    );
  }

  testWidgets(
      'renders landlord rating badge and opens bottom sheet on tap [RF-30.1, RF-30.2, RF-30.3]',
      (tester) async {
    // Provide established reputation
    mockReviewRepo.reputations[testProperty.arrendadorId] = UserReputation(
      userId: testProperty.arrendadorId,
      averageRating: 4.8,
      totalReviews: 12,
      isVerified: true,
    );
    mockReviewRepo.reviews[testProperty.arrendadorId] = [
      Review(
        id: 'rev-1',
        solicitudId: 'sol-1',
        reviewerId: 'usr-reviewer',
        reviewerName: 'María Pérez',
        targetUserId: testProperty.arrendadorId,
        rating: 5,
        comment: 'Excelente propiedad y atención.',
        createdAt: DateTime(2026, 9, 28),
      ),
    ];

    await tester.pumpWidget(buildTestScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify landlord name and rating badge
    expect(find.text('Don Carlos Gómez'), findsOneWidget);
    expect(find.text('Propietario'), findsOneWidget);
    expect(find.text('4.8 ★ (12)'), findsOneWidget);

    // Scroll until rating badge is visible and tap it
    await tester.ensureVisible(find.text('4.8 ★ (12)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('4.8 ★ (12)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify LandlordReputationBottomSheet opened
    expect(find.text('Reputación del Arrendador'), findsOneWidget);
    expect(find.text('María Pérez'), findsOneWidget);
    expect(find.text('Excelente propiedad y atención.'), findsOneWidget);
  });

  testWidgets(
      'renders neutral rating badge when landlord has zero reviews [RF-31.1, CL-24]',
      (tester) async {
    mockReviewRepo.reputations[testProperty.arrendadorId] = UserReputation(
      userId: testProperty.arrendadorId,
      averageRating: null,
      totalReviews: 0,
      isVerified: false,
    );

    await tester.pumpWidget(buildTestScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Sin calificaciones'), findsOneWidget);
  });

  testWidgets(
      'renders provisional rating badge when landlord is verified with zero reviews [RF-31.2, CL-24]',
      (tester) async {
    mockReviewRepo.reputations[testProperty.arrendadorId] = UserReputation(
      userId: testProperty.arrendadorId,
      averageRating: null,
      totalReviews: 0,
      isVerified: true,
    );

    await tester.pumpWidget(buildTestScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('3.0 ★ (Inicial)'), findsOneWidget);
  });

  testWidgets(
      'renders owner rating badge when logged-in user is the property landlord [RF-30.4, QA-5]',
      (tester) async {
    final landlordUser = User(
      id: testProperty.arrendadorId,
      email: 'landlord@test.com',
      role: 'arrendador',
      isPremium: true,
    );
    authProvider.setUser(landlordUser);

    mockReviewRepo.reputations[testProperty.arrendadorId] = UserReputation(
      userId: testProperty.arrendadorId,
      averageRating: 5.0,
      totalReviews: 8,
      isVerified: true,
    );

    await tester.pumpWidget(buildTestScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('5.0 ★ (8)'), findsOneWidget);
  });
}
