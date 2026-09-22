import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/data/models/property_model.dart';
import 'package:vihomeapp/data/models/user_model.dart';
import 'package:vihomeapp/domain/entities/property.dart';
import 'package:vihomeapp/domain/entities/property_type.dart';
import 'package:vihomeapp/domain/entities/user.dart';
import 'package:vihomeapp/domain/repositories/auth_repository.dart';
import 'package:vihomeapp/domain/repositories/property_repository.dart';
import 'package:vihomeapp/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/reset_password_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_in_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_in_with_google_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_out_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/sign_up_usecase.dart';
import 'package:vihomeapp/domain/usecases/auth/update_user_role_usecase.dart';
import 'package:vihomeapp/domain/usecases/property/create_property_usecase.dart';
import 'package:vihomeapp/domain/usecases/property/delete_property_usecase.dart';
import 'package:vihomeapp/domain/usecases/property/get_properties_by_landlord_usecase.dart';
import 'package:vihomeapp/domain/usecases/property/update_property_usecase.dart';
import 'package:vihomeapp/presentation/pages/propiedades/crear_propiedad_page.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/presentation/providers/landlord_properties_provider.dart';
import '../../../fixtures/fixtures.dart';

class MockAuthRepo implements AuthRepository {
  User? currentUser;
  @override
  Future<Either<Failure, User?>> getCurrentUser() async => Right(currentUser);
  @override
  Future<Either<Failure, User>> signInWithEmail({required String email, required String password}) async => Right(currentUser!);
  @override
  Future<Either<Failure, User>> signUp({required String email, required String password, Map<String, dynamic>? metadata}) async => Right(currentUser!);
  @override
  Future<Either<Failure, void>> signOut() async {
    currentUser = null;
    return const Right(null);
  }
  @override
  Future<Either<Failure, User>> signInWithGoogle() async => const Left(AuthFailure('err'));
  @override
  Future<Either<Failure, void>> resetPassword(String email) async => const Right(null);
  @override
  Future<Either<Failure, void>> updatePassword(String newPassword) async => const Right(null);
  @override
  Future<Either<Failure, void>> updateUserRole(String role) async => const Right(null);
  @override
  Stream<Either<Failure, User?>> authStateChanges() => Stream.value(Right(currentUser));
}

class MockPropertyRepo implements PropertyRepository {
  final List<Property> properties = [];

  @override
  Future<Either<Failure, List<Property>>> getPropertiesByLandlord(String landlordId) async =>
      Right(properties.where((p) => p.arrendadorId == landlordId).toList());

  @override
  Future<Either<Failure, Property>> createProperty(Map<String, dynamic> propertyData) async {
    final prop = PropertyModel.fromJson(propertyData);
    properties.add(prop);
    return Right(prop);
  }

  @override
  Future<Either<Failure, Property>> updateProperty(String id, Map<String, dynamic> data) async {
    final index = properties.indexWhere((p) => p.id == id);
    if (index != -1) {
      final updated = PropertyModel.fromJson(data);
      properties[index] = updated;
      return Right(updated);
    }
    return const Left(ServerFailure('Propiedad no encontrada'));
  }

  @override
  Future<Either<Failure, void>> deleteProperty(String id) async {
    properties.removeWhere((p) => p.id == id);
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Property>>> getProperties() async => Right(properties);

  @override
  Future<Either<Failure, List<PropertyType>>> getPropertyTypes() async => const Right([]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepo authRepo;
  late MockPropertyRepo propRepo;
  late AuthProvider authProvider;
  late LandlordPropertiesProvider landlordProvider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    authRepo = MockAuthRepo();
    propRepo = MockPropertyRepo();

    authProvider = AuthProvider(
      signInUseCase: SignInUseCase(authRepo),
      signUpUseCase: SignUpUseCase(authRepo),
      signOutUseCase: SignOutUseCase(authRepo),
      getCurrentUserUseCase: GetCurrentUserUseCase(authRepo),
      signInWithGoogleUseCase: SignInWithGoogleUseCase(authRepo),
      resetPasswordUseCase: ResetPasswordUseCase(authRepo),
      updateUserRoleUseCase: UpdateUserRoleUseCase(authRepo),
    );

    landlordProvider = LandlordPropertiesProvider(
      createPropertyUseCase: CreatePropertyUseCase(propRepo),
      getPropertiesByLandlordUseCase: GetPropertiesByLandlordUseCase(propRepo),
      updatePropertyUseCase: UpdatePropertyUseCase(propRepo),
      deletePropertyUseCase: DeletePropertyUseCase(propRepo),
    );
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<LandlordPropertiesProvider>.value(value: landlordProvider),
      ],
      child: const MaterialApp(
        home: CrearPropiedadPage(),
      ),
    );
  }

  group('CrearPropiedadPage Widget Tests [RF-08.1, RF-08.2, RF-08.3, RF-08.4, CL-05]', () {
    testWidgets('renders all main form fields and buttons', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Título'), findsOneWidget);
      expect(find.text('Dirección'), findsOneWidget);
      expect(find.text('Descripción'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Crear Propiedad'), findsOneWidget);
    });

    testWidgets('validates required fields on submit when empty [RF-08.1]', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final submitBtn = find.widgetWithText(ElevatedButton, 'Crear Propiedad');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump();

      expect(find.text('Requerido'), findsWidgets);
    });

    testWidgets('shows warning dialog when free landlord has reached limit of 1 property [RF-05.2, CL-05]', (tester) async {
      final user = UserModel.fromJson(UserFixtures.validLandlordJson);
      authRepo.currentUser = user;
      await authProvider.signInWithEmail(email: 'user@vihome.app', password: 'pass123');

      final existingProperty = PropertyModel.fromJson(PropertyFixtures.validApartmentBogotaJson);
      propRepo.properties.add(existingProperty);
      await landlordProvider.fetchPropertiesByLandlord(user.id);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Límite Alcanzado'), findsOneWidget);
      expect(find.text('Como usuario estándar solo puedes publicar 1 propiedad. ¡Hazte Premium para publicar propiedades ilimitadas!'), findsOneWidget);
    });
  });
}
