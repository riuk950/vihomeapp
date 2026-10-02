import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import '../../domain/services/fake_services_test.dart';
import '../../fixtures/application_fixtures.dart';

void main() {
  group('RealtimeService Tests [RF-11.1, RF-11.2, RF-11.3, RF-11.4, CL-07]', () {
    late FakeRealtimeService realtimeService;

    setUp(() {
      realtimeService = FakeRealtimeService();
    });

    tearDown(() {
      realtimeService.dispose();
    });

    test('should subscribe to application channel and receive new applications [RF-11.1]', () async {
      final stream = realtimeService.subscribeToTable<Application>(
        table: 'solicitudes',
        filterColumn: 'arrendador_id',
        filterValue: 'usr_landlord_123',
        fromJson: (json) => ApplicationFixtures.pendingApplication,
      );

      expect(realtimeService.channels, contains('solicitudes:arrendador_id=usr_landlord_123'));

      expectLater(
        stream,
        emits(predicate<Application>((app) => app.id == ApplicationFixtures.pendingApplication.id)),
      );

      realtimeService.emitApplication(ApplicationFixtures.pendingApplication);
    });

    test('should track connection status changes for reconnection [RF-11.2]', () async {
      final statuses = <bool>[];
      final sub = realtimeService.connectionStatusStream.listen(statuses.add);

      realtimeService.setConnected(false);
      realtimeService.setConnected(true);

      await Future.delayed(const Duration(milliseconds: 10));
      expect(statuses, equals([false, true]));
      await sub.cancel();
    });

    test('should unsubscribe from single channel cleanly [RF-11.4]', () async {
      realtimeService.subscribeToTable<Application>(
        table: 'solicitudes',
        filterColumn: 'arrendador_id',
        filterValue: 'usr_landlord_123',
        fromJson: (json) => ApplicationFixtures.pendingApplication,
      );

      await realtimeService.unsubscribe('solicitudes:arrendador_id=usr_landlord_123');
      expect(realtimeService.channels, isEmpty);
    });

    test('should unsubscribe from all channels on logout [RF-11.4, CL-07]', () async {
      realtimeService.subscribeToTable<Application>(
        table: 'solicitudes',
        filterColumn: 'arrendador_id',
        filterValue: 'usr_1',
        fromJson: (json) => ApplicationFixtures.pendingApplication,
      );
      realtimeService.subscribeToTable<Application>(
        table: 'solicitudes',
        filterColumn: 'arrendatario_id',
        filterValue: 'usr_2',
        fromJson: (json) => ApplicationFixtures.pendingApplication,
      );

      expect(realtimeService.channels.length, equals(2));

      await realtimeService.unsubscribeAll();
      expect(realtimeService.channels, isEmpty);
    });
  });
}
