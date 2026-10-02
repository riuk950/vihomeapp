import 'package:flutter/material.dart';
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
import 'package:vihomeapp/presentation/pages/landlord/complete_landlord_profile_page.dart';
import 'package:vihomeapp/presentation/pages/tenant/complete_tenant_profile_page.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/presentation/providers/landlord_provider.dart';
import 'package:vihomeapp/presentation/providers/review_provider.dart';
import 'package:vihomeapp/presentation/providers/tenant_provider.dart';

class MockAuthRepo implements AuthRepository {
  User? currentUser;
  @override
  Future<Either<Failure, User?>> getCurrentUser() async => Right(currentUser);
  @override
  Future<Either<Failure, void>> updateUserRole(String role) async => const Right(null);
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
  late MockAuthRepo authRepo;
  late MockTenantRepo tenantRepo;
  late MockLandlordRepo landlordRepo;
  late MockReviewRepo reviewRepo;

  late AuthProvider authProvider;
  late TenantProvider tenantProvider;
  late LandlordProvider landlordProvider;
  late ReviewProvider reviewProvider;

  const testUserId = 'usr_preload_123';
  const sampleTenant = Tenant(
    id: testUserId,
    primerNombre: 'Carlos',
    segundoNombre: 'Andrés',
    primerApellido: 'García',
    segundoApellido: 'Mendoza',
    tipoDocumento: 'CE',
    documento: '55667788',
    telefonoContacto: '3109876543',
    direccionContacto: 'Carrera 7 # 72 - 10',
  );

  const sampleLandlord = Landlord(
    id: testUserId,
    primerNombre: 'Beatriz',
    segundoNombre: 'Elena',
    primerApellido: 'Restrepo',
    segundoApellido: 'Ochoa',
    tipoDocumento: 'CC',
    documento: '99887766',
    telefonoContacto: '3151234567',
    direccionContacto: 'Avenida El Dorado # 68 - 90',
  );

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

    authRepo.currentUser = const User(
      id: testUserId,
      email: 'user@vihome.app',
      name: 'User Preload',
      role: 'arrendatario',
    );
  });

  group('Profile Preload in Complete Profile Forms (HU-36, RF-41)', () {
    testWidgets('CompleteLandlordProfilePage preloads data from TenantProvider when landlord is empty', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      tenantRepo.tenants[testUserId] = sampleTenant;
      await tenantProvider.loadTenantProfile(testUserId);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<TenantProvider>.value(value: tenantProvider),
            ChangeNotifierProvider<LandlordProvider>.value(value: landlordProvider),
            ChangeNotifierProvider<ReviewProvider>.value(value: reviewProvider),
          ],
          child: const MaterialApp(
            home: CompleteLandlordProfilePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Preloaded values should match sampleTenant
      expect(find.text('Carlos'), findsOneWidget);
      expect(find.text('Andrés'), findsOneWidget);
      expect(find.text('García'), findsOneWidget);
      expect(find.text('Mendoza'), findsOneWidget);
      expect(find.text('55667788'), findsOneWidget);
      expect(find.text('Carrera 7 # 72 - 10'), findsOneWidget);
    });

    testWidgets('CompleteTenantProfilePage preloads data from LandlordProvider when tenant is empty', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      landlordRepo.landlords[testUserId] = sampleLandlord;
      await landlordProvider.loadLandlordProfile(testUserId);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<TenantProvider>.value(value: tenantProvider),
            ChangeNotifierProvider<LandlordProvider>.value(value: landlordProvider),
            ChangeNotifierProvider<ReviewProvider>.value(value: reviewProvider),
          ],
          child: const MaterialApp(
            home: CompleteTenantProfilePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Preloaded values should match sampleLandlord
      expect(find.text('Beatriz'), findsOneWidget);
      expect(find.text('Elena'), findsOneWidget);
      expect(find.text('Restrepo'), findsOneWidget);
      expect(find.text('Ochoa'), findsOneWidget);
      expect(find.text('99887766'), findsOneWidget);
      expect(find.text('Avenida El Dorado # 68 - 90'), findsOneWidget);
    });
  });
}
