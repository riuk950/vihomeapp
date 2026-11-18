import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vihomeapp/app/app.dart';
import 'package:vihomeapp/core/ads/ad_manager.dart';
import 'package:vihomeapp/presentation/providers/providers.dart';
import 'package:vihomeapp/domain/entities/project.dart';
import 'package:vihomeapp/domain/entities/user.dart';
import 'package:vihomeapp/domain/entities/property.dart';
import 'package:vihomeapp/domain/entities/property_type.dart';

import 'package:vihomeapp/domain/entities/onboarding_state.dart';
import 'package:vihomeapp/domain/repositories/onboarding_repository.dart';
import 'package:vihomeapp/domain/usecases/onboarding/complete_onboarding_usecase.dart';
import 'package:vihomeapp/domain/usecases/onboarding/get_onboarding_status_usecase.dart';

// Mocks
class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  bool get isAuthenticated => false;

  @override
  bool get isGuest => true;

  @override
  bool get hasExpiredSession => false;

  @override
  bool get isInitialized => true;

  @override
  User? get user => null;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

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
  void selectType(PropertyType? type) {}

  @override
  void clearError() {}

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
  List<Property> get properties => [];

  @override
  bool get isLoading => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockApplicationProvider extends ChangeNotifier
    implements ApplicationProvider {
  @override
  int get unreadLandlordCount => 0;

  @override
  int get unreadTenantCount => 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockProjectProvider extends ChangeNotifier implements ProjectProvider {
  @override
  List<Project> get projects => [];

  @override
  List<Project> get filteredProjects => [];

  @override
  String? get selectedFilter => null;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  Future<void> fetchProjects() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAdManager implements AdManager {
  @override
  String get bannerAdUnitId => '';

  @override
  void showInterstitialAd({required bool isPremium}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockSubscriptionProvider extends ChangeNotifier
    implements SubscriptionProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockReviewProvider extends ChangeNotifier implements ReviewProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockOnboardingRepository implements OnboardingRepository {
  @override
  Future<OnboardingState> getOnboardingState() async =>
      const OnboardingState(hasSeenOnboarding: true, completionReason: OnboardingCompletionReason.completed, lastCompletedStep: 4);
  @override
  Future<bool> markOnboardingSeen({
    required OnboardingCompletionReason reason,
    required int lastStep,
  }) async =>
      true;
}

class MockOnboardingProvider extends OnboardingProvider {
  MockOnboardingProvider()
      : super(
          getOnboardingStatusUseCase:
              GetOnboardingStatusUseCase(MockOnboardingRepository()),
          completeOnboardingUseCase:
              CompleteOnboardingUseCase(MockOnboardingRepository()),
        );
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
    getIt.registerFactory<ProjectProvider>(() => MockProjectProvider());
    getIt.registerFactory<SubscriptionProvider>(() => MockSubscriptionProvider());
    getIt.registerFactory<ReviewProvider>(() => MockReviewProvider());
    getIt.registerFactory<OnboardingProvider>(() => MockOnboardingProvider());
    getIt.registerLazySingleton<AdManager>(() => MockAdManager());
    final mockOnboardingRepo = MockOnboardingRepository();
    getIt.registerLazySingleton<GetOnboardingStatusUseCase>(
        () => GetOnboardingStatusUseCase(mockOnboardingRepo));
    getIt.registerLazySingleton<CompleteOnboardingUseCase>(
        () => CompleteOnboardingUseCase(mockOnboardingRepo));
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
