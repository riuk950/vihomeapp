import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vihomeapp/app/app.dart';
import 'package:vihomeapp/presentation/providers/providers.dart';
import 'package:vihomeapp/domain/entities/user.dart';

// Mocks
class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  bool get isAuthenticated => false;

  @override
  User? get user => null;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockPropertyProvider extends ChangeNotifier implements PropertyProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockTenantProvider extends ChangeNotifier implements TenantProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockLandlordProvider extends ChangeNotifier implements LandlordProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockLandlordPropertiesProvider extends ChangeNotifier
    implements LandlordPropertiesProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockApplicationProvider extends ChangeNotifier
    implements ApplicationProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final getIt = GetIt.instance;

  setUpAll(() async {
    dotenv.testLoad(
        fileInput: 'DEBUG_MODE=true\nAPI_BASE_URL=https://example.com');
  });

  setUp(() {
    getIt.reset();
    // Register basic mocks
    getIt.registerFactory<AuthProvider>(() => MockAuthProvider());
    getIt.registerFactory<PropertyProvider>(() => MockPropertyProvider());
    getIt.registerFactory<TenantProvider>(() => MockTenantProvider());
    getIt.registerFactory<LandlordProvider>(() => MockLandlordProvider());
    getIt.registerFactory<LandlordPropertiesProvider>(
        () => MockLandlordPropertiesProvider());
    getIt.registerFactory<ApplicationProvider>(() => MockApplicationProvider());
  });

  group('FlavorApp Widget Tests', () {
    testWidgets('should render MaterialApp.router',
        (WidgetTester tester) async {
      await tester.pumpWidget(const FlavorApp());
      await tester.pump(const Duration(seconds: 3));

      // Verify MaterialApp is present
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
