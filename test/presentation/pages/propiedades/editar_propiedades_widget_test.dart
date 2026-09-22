import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/data/models/property_model.dart';
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
import 'package:vihomeapp/presentation/pages/propiedades/editar_propiedades_page.dart';
import 'package:vihomeapp/presentation/providers/auth_provider.dart';
import 'package:vihomeapp/presentation/providers/landlord_properties_provider.dart';
import '../../../fixtures/fixtures.dart';

// 1x1 transparent PNG
final List<int> _transparentImage = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
);

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _FakeHttpClient();
  }
}

class _FakeHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Duration? connectionTimeout;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  int? maxConnectionsPerHost;
  @override
  String? userAgent;

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpRequest();
}

class _FakeHttpRequest implements HttpClientRequest {
  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<HttpClientResponse> close() async => _FakeHttpResponse();
}

class _FakeHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _FakeHttpResponse extends Stream<List<int>> implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => _transparentImage.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream.value(_transparentImage).listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthRepo implements AuthRepository {
  User? currentUser;
  @override
  Future<Either<Failure, User?>> getCurrentUser() async => Right(currentUser);
  @override
  Future<Either<Failure, User>> signInWithEmail({required String email, required String password}) async => Right(currentUser!);
  @override
  Future<Either<Failure, User>> signUp({required String email, required String password, Map<String, dynamic>? metadata}) async => Right(currentUser!);
  @override
  Future<Either<Failure, void>> signOut() async => const Right(null);
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
  @override
  Future<Either<Failure, List<Property>>> getPropertiesByLandlord(String landlordId) async => const Right([]);
  @override
  Future<Either<Failure, Property>> createProperty(Map<String, dynamic> propertyData) async =>
      Right(PropertyModel.fromJson(propertyData));
  @override
  Future<Either<Failure, Property>> updateProperty(String id, Map<String, dynamic> data) async =>
      Right(PropertyModel.fromJson(data));
  @override
  Future<Either<Failure, void>> deleteProperty(String id) async => const Right(null);
  @override
  Future<Either<Failure, List<Property>>> getProperties() async => const Right([]);
  @override
  Future<Either<Failure, List<PropertyType>>> getPropertyTypes() async => const Right([]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = TestHttpOverrides();

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

  Widget createWidgetUnderTest(Property property) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<LandlordPropertiesProvider>.value(value: landlordProvider),
      ],
      child: MaterialApp(
        home: EditarPropiedadesPage(property: property),
      ),
    );
  }

  group('EditarPropiedadesPage Widget Tests [RF-09.1, RF-09.2, RF-09.3]', () {
    testWidgets('preloads property data in form fields correctly [RF-09.1]', (tester) async {
      final property = PropertyModel.fromJson(PropertyFixtures.validHouseMedellinJson);

      await tester.pumpWidget(createWidgetUnderTest(property));
      await tester.pump();

      expect(find.text('Editar Propiedad'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is TextFormField && w.controller?.text == 'Casa campestre en El Poblado'),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((w) => w is TextFormField && w.controller?.text == 'Carrera 25 # 10-50'),
        findsOneWidget,
      );
      expect(find.text('Guardar Cambios'), findsOneWidget);
    });

    testWidgets('prevents deleting the last photo without replacement [RF-09.2]', (tester) async {
      final singlePhotoJson = Map<String, dynamic>.from(PropertyFixtures.validHouseMedellinJson);
      singlePhotoJson['fotos'] = ['https://storage.vihome.app/properties/prop_single_01.jpg'];
      final property = PropertyModel.fromJson(singlePhotoJson);

      await tester.pumpWidget(createWidgetUnderTest(property));
      await tester.pump();

      final closeIcon = find.byIcon(Icons.close);
      expect(closeIcon, findsOneWidget);

      await tester.ensureVisible(closeIcon);
      await tester.tap(closeIcon);
      await tester.pump();

      expect(find.text('La propiedad debe tener al menos una foto.'), findsOneWidget);
    });
  });
}
