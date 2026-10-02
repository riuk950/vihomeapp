import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/domain/entities/landlord.dart';
import 'package:vihomeapp/domain/entities/review.dart';
import 'package:vihomeapp/domain/entities/tenant.dart';
import 'package:vihomeapp/domain/entities/user.dart';
import 'package:vihomeapp/domain/entities/user_reputation.dart';
import 'package:vihomeapp/domain/repositories/review_repository.dart';
import 'package:vihomeapp/presentation/pages/landlord/complete_landlord_profile_page.dart';
import 'package:vihomeapp/presentation/pages/tenant/complete_tenant_profile_page.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/presentation/providers/landlord_provider.dart';
import 'package:vihomeapp/presentation/providers/review_provider.dart';
import 'package:vihomeapp/presentation/providers/tenant_provider.dart';
import 'package:vihomeapp/presentation/widgets/btn_primary.dart';

class MockReviewRepository implements ReviewRepository {
  final List<Review> registeredReviews = [];
  bool shouldThrowNetworkError = false;
  int registerVerifiedCalls = 0;

  @override
  Future<Review> registerVerifiedUserReview({
    required String userId,
    String? userName,
  }) async {
    registerVerifiedCalls++;
    if (shouldThrowNetworkError) {
      throw Exception('Fallo simulado de red en Supabase');
    }

    final existing = registeredReviews.cast<Review?>().firstWhere(
      (r) => r?.solicitudId == null && r?.targetUserId == userId,
      orElse: () => null,
    );
    if (existing != null) return existing;

    final review = Review(
      id: 'rev-verified-${registeredReviews.length + 1}',
      solicitudId: null,
      reviewerId: userId,
      reviewerName: userName ?? 'Sistema ViHome',
      targetUserId: userId,
      rating: 3,
      comment: 'Usuario verificado',
      createdAt: DateTime.now(),
    );
    registeredReviews.add(review);
    return review;
  }

  @override
  Future<UserReputation> getUserReputation(
    String userId, {
    bool isVerified = false,
    String? userName,
  }) async {
    final userReviews =
        registeredReviews.where((r) => r.targetUserId == userId).toList();
    if (userReviews.isEmpty) {
      return UserReputation(
        userId: userId,
        userName: userName,
        isVerified: isVerified,
        averageRating: null,
        totalReviews: 0,
      );
    }
    final sum = userReviews.fold<int>(0, (prev, r) => prev + r.rating);
    return UserReputation(
      userId: userId,
      userName: userName,
      isVerified: isVerified,
      averageRating: sum / userReviews.length,
      totalReviews: userReviews.length,
    );
  }

  @override
  Future<List<Review>> getUserReviews(String userId) async {
    return registeredReviews.where((r) => r.targetUserId == userId).toList();
  }

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
  Future<bool> canUserRateApplication({
    required String solicitudId,
    required String userId,
  }) async =>
      false;
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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockLandlordProvider extends ChangeNotifier implements LandlordProvider {
  final bool _isLoading = false;
  Landlord? _landlord;
  bool shouldSucceed = true;
  int saveCalls = 0;

  @override
  bool get isLoading => _isLoading;

  @override
  Landlord? get landlord => _landlord;

  @override
  String? get errorMessage => null;

  @override
  void clearError() {}

  @override
  Future<bool> saveLandlordProfile(Landlord landlord) async {
    saveCalls++;
    if (shouldSucceed) {
      _landlord = landlord;
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockTenantProvider extends ChangeNotifier implements TenantProvider {
  final bool _isLoading = false;
  Tenant? _tenant;
  bool shouldSucceed = true;
  int saveCalls = 0;

  @override
  bool get isLoading => _isLoading;

  @override
  Tenant? get tenant => _tenant;

  @override
  String? get errorMessage => null;

  @override
  void clearError() {}

  @override
  Future<bool> saveTenantProfile(Tenant tenant) async {
    saveCalls++;
    if (shouldSucceed) {
      _tenant = tenant;
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockReviewRepository mockReviewRepo;
  late ReviewProvider reviewProvider;
  late MockAuthProvider mockAuthProvider;
  late MockLandlordProvider mockLandlordProvider;
  late MockTenantProvider mockTenantProvider;

  setUp(() {
    mockReviewRepo = MockReviewRepository();
    reviewProvider = ReviewProvider(mockReviewRepo);
    mockAuthProvider = MockAuthProvider();
    mockLandlordProvider = MockLandlordProvider();
    mockTenantProvider = MockTenantProvider();
  });

  Widget buildLandlordTestApp(GoRouter router) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<LandlordProvider>.value(
            value: mockLandlordProvider),
        ChangeNotifierProvider<ReviewProvider>.value(value: reviewProvider),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  Widget buildTenantTestApp(GoRouter router) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<TenantProvider>.value(
            value: mockTenantProvider),
        ChangeNotifierProvider<ReviewProvider>.value(value: reviewProvider),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('Verified User Review Integration Tests [RF-36, CL-31]', () {
    testWidgets(
        'Al completar perfil de arrendador se registra automáticamente reseña de 3 estrellas con comentario "Usuario verificado" (RF-36.1, RF-36.3)',
        (tester) async {
      mockAuthProvider.user = const User(
        id: 'landlord-uuid-1',
        email: 'landlord@vihome.co',
      );

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Root')),
          ),
          GoRoute(
            path: '/complete-landlord',
            builder: (context, state) => const CompleteLandlordProfilePage(),
          ),
        ],
      );

      await tester.pumpWidget(buildLandlordTestApp(router));
      await tester.pumpAndSettle();

      router.push('/complete-landlord');
      await tester.pumpAndSettle();

      // Completar campos obligatorios
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Primer Nombre'), 'Carlos');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Primer Apellido'), 'Restrepo');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Número de Documento'),
          '10203040');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Dirección de Contacto'),
          'Calle 100 # 15-20');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Teléfono de Contacto'),
          '573001234567');

      await tester.ensureVisible(find.widgetWithText(BtnPrimary, 'Guardar'));
      await tester.tap(find.widgetWithText(BtnPrimary, 'Guardar'));
      await tester.pumpAndSettle();

      // Validar que se guardó el perfil de arrendador
      expect(mockLandlordProvider.saveCalls, equals(1));

      // Validar que se registró la calificación de verificación en Supabase
      expect(mockReviewRepo.registerVerifiedCalls, equals(1));
      expect(mockReviewRepo.registeredReviews.length, equals(1));

      final review = mockReviewRepo.registeredReviews.first;
      expect(review.rating, equals(3));
      expect(review.comment, equals('Usuario verificado'));
      expect(review.solicitudId, isNull);
      expect(review.targetUserId, equals('landlord-uuid-1'));
      expect(review.reviewerName, equals('Carlos Restrepo'));

      // Validar reactividad: ReviewProvider tiene en memoria la reputación de 3.0
      final rep = reviewProvider.getReputationFor('landlord-uuid-1');
      expect(rep, isNotNull);
      expect(rep!.averageRating, equals(3.0));
      expect(rep.totalReviews, equals(1));
      expect(rep.isVerified, isTrue);

      // Validar que volvió a Root y mostró el SnackBar
      expect(find.text('Perfil de arrendador completado exitosamente'),
          findsOneWidget);
    });

    testWidgets(
        'Al completar perfil de arrendatario se registra automáticamente reseña de 3 estrellas con comentario "Usuario verificado" (RF-36.2, RF-36.3)',
        (tester) async {
      mockAuthProvider.user = const User(
        id: 'tenant-uuid-1',
        email: 'tenant@vihome.co',
      );

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Root')),
          ),
          GoRoute(
            path: '/complete-tenant',
            builder: (context, state) => const CompleteTenantProfilePage(),
          ),
        ],
      );

      await tester.pumpWidget(buildTenantTestApp(router));
      await tester.pumpAndSettle();

      router.push('/complete-tenant');
      await tester.pumpAndSettle();

      // Completar campos obligatorios
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Primer Nombre'), 'Ana');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Primer Apellido'), 'Gómez');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Número de Documento'),
          '80706050');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Dirección de Contacto'),
          'Carrera 7 # 45-10');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Teléfono de Contacto'),
          '573109876543');

      await tester.ensureVisible(find.widgetWithText(BtnPrimary, 'Guardar'));
      await tester.tap(find.widgetWithText(BtnPrimary, 'Guardar'));
      await tester.pumpAndSettle();

      // Validar que se guardó el perfil de arrendatario
      expect(mockTenantProvider.saveCalls, equals(1));

      // Validar que se registró la calificación de verificación
      expect(mockReviewRepo.registerVerifiedCalls, equals(1));
      expect(mockReviewRepo.registeredReviews.length, equals(1));

      final review = mockReviewRepo.registeredReviews.first;
      expect(review.rating, equals(3));
      expect(review.comment, equals('Usuario verificado'));
      expect(review.solicitudId, isNull);
      expect(review.targetUserId, equals('tenant-uuid-1'));
      expect(review.reviewerName, equals('Ana Gómez'));

      // Validar reactividad: ReviewProvider tiene en memoria la reputación de 3.0
      final rep = reviewProvider.getReputationFor('tenant-uuid-1');
      expect(rep, isNotNull);
      expect(rep!.averageRating, equals(3.0));
      expect(rep.totalReviews, equals(1));
      expect(rep.isVerified, isTrue);

      // Validar que volvió a Root y mostró el SnackBar
      expect(
          find.text('Perfil completado exitosamente'), findsOneWidget);
    });

    testWidgets(
        'Idempotencia: No duplica la calificación de verificación si se guarda el perfil nuevamente (RF-36.4)',
        (tester) async {
      mockAuthProvider.user = const User(
        id: 'landlord-uuid-idempotent',
        email: 'landlord@vihome.co',
      );

      // Pre-cargar ya una calificación de verificación
      await reviewProvider.registerVerifiedUserReview(
        userId: 'landlord-uuid-idempotent',
        userName: 'Carlos Restrepo',
      );
      expect(mockReviewRepo.registeredReviews.length, equals(1));

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Root')),
          ),
          GoRoute(
            path: '/complete-landlord',
            builder: (context, state) => const CompleteLandlordProfilePage(),
          ),
        ],
      );

      await tester.pumpWidget(buildLandlordTestApp(router));
      await tester.pumpAndSettle();

      router.push('/complete-landlord');
      await tester.pumpAndSettle();

      // Completar campos y guardar de nuevo
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Primer Nombre'), 'Carlos');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Primer Apellido'), 'Restrepo');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Número de Documento'),
          '10203040');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Dirección de Contacto'),
          'Calle 100 # 15-20');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Teléfono de Contacto'),
          '573001234567');

      await tester.ensureVisible(find.widgetWithText(BtnPrimary, 'Guardar'));
      await tester.tap(find.widgetWithText(BtnPrimary, 'Guardar'));
      await tester.pumpAndSettle();

      // Validar que NO se añadió una segunda reseña (se mantuvo en 1)
      expect(mockReviewRepo.registeredReviews.length, equals(1));
    });

    testWidgets(
        'Resiliencia: Si el servicio de calificación falla, el guardado de perfil culmina con éxito (RF-36.5)',
        (tester) async {
      mockAuthProvider.user = const User(
        id: 'landlord-resilient',
        email: 'landlord@vihome.co',
      );

      // Simular fallo de red en calificaciones
      mockReviewRepo.shouldThrowNetworkError = true;

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Root')),
          ),
          GoRoute(
            path: '/complete-landlord',
            builder: (context, state) => const CompleteLandlordProfilePage(),
          ),
        ],
      );

      await tester.pumpWidget(buildLandlordTestApp(router));
      await tester.pumpAndSettle();

      router.push('/complete-landlord');
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Primer Nombre'), 'Carlos');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Primer Apellido'), 'Restrepo');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Número de Documento'),
          '10203040');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Dirección de Contacto'),
          'Calle 100 # 15-20');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Teléfono de Contacto'),
          '573001234567');

      await tester.ensureVisible(find.widgetWithText(BtnPrimary, 'Guardar'));
      await tester.tap(find.widgetWithText(BtnPrimary, 'Guardar'));
      await tester.pumpAndSettle();

      // Validar que el perfil se guardó correctamente sin excepciones no controladas
      expect(mockLandlordProvider.saveCalls, equals(1));
      expect(
          find.text('Perfil de arrendador completado exitosamente'),
          findsOneWidget);
    });
  });
}
