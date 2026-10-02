import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/domain/entities/landlord.dart';
import 'package:vihomeapp/domain/entities/review.dart';
import 'package:vihomeapp/domain/entities/tenant.dart';
import 'package:vihomeapp/domain/entities/user.dart';
import 'package:vihomeapp/domain/entities/user_reputation.dart';
import 'package:vihomeapp/domain/repositories/auth_repository.dart';
import 'package:vihomeapp/domain/repositories/landlord_repository.dart';
import 'package:vihomeapp/domain/repositories/review_repository.dart';
import 'package:vihomeapp/domain/repositories/tenant_repository.dart';
import 'package:vihomeapp/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/reset_password_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_in_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_in_with_google_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_out_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_up_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/update_user_role_usecase.dart';
import 'package:vihomeapp/domain/usecases/landlord/get_landlord_profile_usecase.dart';
import 'package:vihomeapp/domain/usecases/landlord/save_landlord_profile_usecase.dart';
import 'package:vihomeapp/domain/usecases/tenant/get_tenant_profile_usecase.dart';
import 'package:vihomeapp/domain/usecases/tenant/save_tenant_profile_usecase.dart';
import 'package:vihomeapp/presentation/pages/navegation/perfil_page.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/presentation/providers/landlord_provider.dart';
import 'package:vihomeapp/presentation/providers/review_provider.dart';
import 'package:vihomeapp/presentation/providers/tenant_provider.dart';

class MockAuthRepo implements AuthRepository {
  User? currentUser;
  int updateRoleCalls = 0;
  String? lastUpdatedRole;

  @override
  Future<Either<Failure, User?>> getCurrentUser() async => Right(currentUser);

  @override
  Future<Either<Failure, void>> updateUserRole(String role) async {
    updateRoleCalls++;
    lastUpdatedRole = role;
    if (currentUser != null) {
      currentUser = currentUser!.copyWith(role: role);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, User>> signInWithEmail({required String email, required String password}) async => throw UnimplementedError();
  @override
  Future<Either<Failure, User>> signUp({required String email, required String password, Map<String, dynamic>? metadata}) async => throw UnimplementedError();
  @override
  Future<Either<Failure, void>> signOut() async => const Right(null);
  @override
  Future<Either<Failure, User>> signInWithGoogle() async => throw UnimplementedError();
  @override
  Future<Either<Failure, void>> resetPassword(String email) async => throw UnimplementedError();
  @override
  Future<Either<Failure, void>> updatePassword(String newPassword) async => throw UnimplementedError();
  @override
  Stream<Either<Failure, User?>> authStateChanges() => Stream.value(Right(currentUser));
}

class MockTenantRepo implements TenantRepository {
  final Map<String, Tenant> tenants = {};

  @override
  Future<Either<Failure, Tenant>> getTenantProfile(String userId) async {
    final t = tenants[userId];
    if (t == null) return const Left(ServerFailure('Not found'));
    return Right(t);
  }

  @override
  Future<Either<Failure, void>> saveTenantProfile(Tenant tenant) async {
    tenants[tenant.id] = tenant;
    return const Right(null);
  }
}

class MockLandlordRepo implements LandlordRepository {
  final Map<String, Landlord> landlords = {};

  @override
  Future<Either<Failure, Landlord>> getLandlordProfile(String userId) async {
    final l = landlords[userId];
    if (l == null) return const Left(ServerFailure('Not found'));
    return Right(l);
  }

  @override
  Future<Either<Failure, void>> saveLandlordProfile(Landlord landlord) async {
    landlords[landlord.id] = landlord;
    return const Right(null);
  }
}

class MockReviewRepo implements ReviewRepository {
  @override
  Future<Review> createReview({required String solicitudId, required String reviewerId, required String targetUserId, required int rating, String? comment, String? reviewerName}) async => throw UnimplementedError();
  @override
  Future<UserReputation> getUserReputation(String userId, {bool isVerified = false, String? userName}) async =>
      UserReputation(userId: userId, userName: userName, isVerified: isVerified);
  @override
  Future<List<Review>> getUserReviews(String userId) async => [];
  @override
  Future<bool> canUserRateApplication({required String solicitudId, required String userId}) async => false;
  @override
  Future<Review> registerVerifiedUserReview({required String userId, String? userName}) async =>
      Review(id: 'r1', solicitudId: null, reviewerId: userId, reviewerName: userName, targetUserId: userId, rating: 3, comment: 'Usuario verificado', createdAt: DateTime.now());
}

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'FLAVOR=dev\nAPI_URL=https://dev.example.com\n');
  });

  late MockAuthRepo authRepo;
  late MockTenantRepo tenantRepo;
  late MockLandlordRepo landlordRepo;
  late MockReviewRepo reviewRepo;

  late AuthProvider authProvider;
  late TenantProvider tenantProvider;
  late LandlordProvider landlordProvider;
  late ReviewProvider reviewProvider;

  const testUserId = 'usr_switch_123';
  const sampleTenant = Tenant(
    id: testUserId,
    primerNombre: 'Diego',
    primerApellido: 'Villate',
    tipoDocumento: 'CC',
    documento: '12345678',
    telefonoContacto: '3001234567',
    direccionContacto: 'Calle 100 # 20 - 30',
  );

  final sampleLandlord = sampleTenant.toLandlord();

  setUp(() {
    authRepo = MockAuthRepo();
    tenantRepo = MockTenantRepo();
    landlordRepo = MockLandlordRepo();
    reviewRepo = MockReviewRepo();

    authProvider = AuthProvider(
      getCurrentUserUseCase: GetCurrentUserUseCase(authRepo),
      signInUseCase: SignInUseCase(authRepo),
      signUpUseCase: SignUpUseCase(authRepo),
      signOutUseCase: SignOutUseCase(authRepo),
      signInWithGoogleUseCase: SignInWithGoogleUseCase(authRepo),
      resetPasswordUseCase: ResetPasswordUseCase(authRepo),
      updateUserRoleUseCase: UpdateUserRoleUseCase(authRepo),
    );

    tenantProvider = TenantProvider(
      getTenantProfileUseCase: GetTenantProfileUseCase(tenantRepo),
      saveTenantProfileUseCase: SaveTenantProfileUseCase(tenantRepo),
    );

    landlordProvider = LandlordProvider(
      getLandlordProfileUseCase: GetLandlordProfileUseCase(landlordRepo),
      saveLandlordProfileUseCase: SaveLandlordProfileUseCase(landlordRepo),
    );

    reviewProvider = ReviewProvider(reviewRepo);
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<TenantProvider>.value(value: tenantProvider),
        ChangeNotifierProvider<LandlordProvider>.value(value: landlordProvider),
        ChangeNotifierProvider<ReviewProvider>.value(value: reviewProvider),
      ],
      child: const MaterialApp(
        home: PerfilPage(),
      ),
    );
  }

  group('Role Switch Persistence and Navigation Integration Tests (HU-32..35, RF-37..40)', () {
    testWidgets('Arrendatario sees "Conviértete en Arrendador" and on success does NOT redirect if verified', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      authRepo.currentUser = const User(
        id: testUserId,
        email: 'diego@vihome.app',
        name: 'Diego Villate',
        role: 'arrendatario',
      );
      await authProvider.reloadUser();

      // Tenant profile is complete
      tenantRepo.tenants[testUserId] = sampleTenant;
      await tenantProvider.loadTenantProfile(testUserId);

      // Simulating synchronization: landlord repo already receives synced profile
      landlordRepo.landlords[testUserId] = sampleLandlord;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // 1. Verify "Conviértete en Arrendador" banner is displayed
      expect(find.text('Conviértete en Arrendador'), findsOneWidget);
      expect(find.text('Cambiar a rol Arrendatario'), findsNothing);

      // 2. Tap on "Conviértete en Arrendador"
      await tester.tap(find.text('Conviértete en Arrendador'));
      await tester.pumpAndSettle();

      // 3. Confirmation dialog appears
      expect(find.text('¿Estás seguro de que quieres convertirte en Arrendador? Podrás publicar tus propiedades y gestionar tus arriendos.'), findsOneWidget);
      expect(find.text('Confirmar'), findsOneWidget);

      // 4. Confirm action
      await tester.tap(find.text('Confirmar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // 5. Verify success SnackBar without redirection
      expect(find.text('¡Tu rol ahora es Arrendador! Ya puedes publicar propiedades'), findsOneWidget);
      expect(authProvider.user?.role, 'arrendador');
      expect(landlordProvider.isVerified, isTrue);
    });

    testWidgets('Arrendador sees "Cambiar a rol Arrendatario" and switches back smoothly without data loss', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      authRepo.currentUser = const User(
        id: testUserId,
        email: 'diego@vihome.app',
        name: 'Diego Villate',
        role: 'arrendador',
      );
      await authProvider.reloadUser();

      landlordRepo.landlords[testUserId] = sampleLandlord;
      await landlordProvider.loadLandlordProfile(testUserId);

      tenantRepo.tenants[testUserId] = sampleTenant;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // 1. Verify "Cambiar a rol Arrendatario" banner is displayed
      expect(find.text('Cambiar a rol Arrendatario'), findsOneWidget);
      expect(find.text('Conviértete en Arrendador'), findsNothing);

      // 2. Tap on "Cambiar a rol Arrendatario"
      await tester.tap(find.text('Cambiar a rol Arrendatario'));
      await tester.pumpAndSettle();

      // 3. Confirmation dialog appears
      expect(find.text('¿Estás seguro de que deseas cambiar al rol de Arrendatario? Podrás explorar propiedades y enviar solicitudes de arriendo.'), findsOneWidget);

      // 4. Confirm
      await tester.tap(find.text('Confirmar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // 5. Verify success SnackBar for tenant
      expect(find.text('¡Tu rol ahora es Arrendatario! Ya puedes explorar y solicitar arriendos'), findsOneWidget);
      expect(authProvider.user?.role, 'arrendatario');
      expect(tenantProvider.isVerified, isTrue);
    });

    testWidgets('Shows MsnUserVerificado for both roles when profile is verified', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      authRepo.currentUser = const User(
        id: testUserId,
        email: 'diego@vihome.app',
        name: 'Diego Villate',
        role: 'arrendador',
      );
      await authProvider.reloadUser();

      landlordRepo.landlords[testUserId] = sampleLandlord;
      await landlordProvider.loadLandlordProfile(testUserId);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Verified banner should be shown for landlord
      expect(find.text('Perfil Verificado'), findsOneWidget);
      expect(find.text('Completa tu perfil'), findsNothing);
    });
  });
}
