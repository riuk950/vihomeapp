import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/repositories/application_repository.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';
import '../../domain/services/fake_services_test.dart';
import '../../fixtures/application_fixtures.dart';

class FakeApplicationRepository implements ApplicationRepository {
  List<Application> landlordApps = [];
  List<Application> tenantApps = [];

  @override
  Future<List<Application>> getLandlordApplications(String landlordId) async {
    return landlordApps;
  }

  @override
  Future<List<Application>> getTenantApplications(String tenantId) async {
    return tenantApps;
  }

  @override
  Future<bool> updateApplicationStatus(String applicationId, String status) async {
    return true;
  }

  @override
  Future<Application> createApplication(Application application) async {
    return application;
  }

  @override
  Future<bool> hasApplicationForProperty(String tenantId, String propertyId) async {
    return false;
  }

  @override
  Future<bool> hasAcceptedApplicationsForProperty(String propertyId) async {
    return false;
  }

  @override
  Future<bool> deleteApplication(String applicationId) async {
    return true;
  }

  @override
  Future<bool> deleteApplicationsForProperty(String propertyId) async {
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApplicationProvider Realtime Integration Tests [RF-11.1, RF-11.2, RF-11.4]', () {
    late FakeApplicationRepository fakeRepo;
    late FakeRealtimeService fakeRealtime;
    late ApplicationProvider provider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      fakeRepo = FakeApplicationRepository();
      fakeRealtime = FakeRealtimeService();
      provider = ApplicationProvider(fakeRepo, realtimeService: fakeRealtime);
    });

    tearDown(() {
      provider.dispose();
      fakeRealtime.dispose();
    });

    test('should subscribe to realtime events when fetching landlord applications [RF-11.1]', () async {
      fakeRepo.landlordApps = [ApplicationFixtures.pendingApplication];

      await provider.fetchLandlordApplications('usr_landlord_1');

      expect(provider.applications.length, equals(1));
      expect(fakeRealtime.channels, contains('solicitudes:arrendador_id=usr_landlord_1'));
    });

    test('should reactively receive new application from realtime stream [RF-11.1]', () async {
      fakeRepo.landlordApps = [];
      await provider.fetchLandlordApplications('usr_landlord_1');
      expect(provider.applications, isEmpty);

      // Simulate a new application arriving from backend via repository reload
      fakeRepo.landlordApps = [ApplicationFixtures.pendingApplication];
      fakeRealtime.emitApplication(ApplicationFixtures.pendingApplication);

      // Yield event loop
      await Future.delayed(const Duration(milliseconds: 10));

      expect(provider.applications.length, equals(1));
    });

    test('should unsubscribe and clear channels on provider clear/dispose [RF-11.4]', () async {
      fakeRepo.landlordApps = [ApplicationFixtures.pendingApplication];
      await provider.fetchLandlordApplications('usr_landlord_1');
      expect(fakeRealtime.channels.isNotEmpty, isTrue);

      provider.clear();
      expect(provider.applications, isEmpty);
      expect(fakeRealtime.channels, isEmpty);
    });
  });
}
