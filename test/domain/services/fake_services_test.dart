import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/domain/services/i_realtime_service.dart';
import 'package:vihomeapp/domain/services/i_iap_service.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import '../../fixtures/application_fixtures.dart';

class FakeRealtimeService implements IRealtimeService {
  final _controller = StreamController<Application>.broadcast();
  final _connController = StreamController<bool>.broadcast();
  bool _connected = true;
  final List<String> channels = [];

  @override
  bool get isConnected => _connected;

  @override
  Stream<bool> get connectionStatusStream => _connController.stream;

  @override
  Stream<T> subscribeToTable<T>({
    required String table,
    required String filterColumn,
    required dynamic filterValue,
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    channels.add('$table:$filterColumn=$filterValue');
    return _controller.stream as Stream<T>;
  }

  void emitApplication(Application app) {
    _controller.add(app);
  }

  void setConnected(bool connected) {
    _connected = connected;
    _connController.add(connected);
  }

  @override
  Future<void> unsubscribe(String channel) async {
    channels.remove(channel);
  }

  @override
  Future<void> unsubscribeAll() async {
    channels.clear();
  }

  void dispose() {
    _controller.close();
    _connController.close();
  }
}

class FakeIapService implements IIapService {
  bool available = true;
  bool shouldSucceed = true;
  final _purchaseController = StreamController<IapPurchaseEvent>.broadcast();

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<List<IapProduct>> getProducts(Set<String> productIds) async {
    return productIds.map((id) => IapProduct(id: id, title: 'Plan Premium', price: '\$ 19.900')).toList();
  }

  @override
  Future<bool> buyProduct(String productId) async {
    if (shouldSucceed) {
      _purchaseController.add(IapPurchaseEvent(productId: productId, status: IapPurchaseStatus.purchased));
      return true;
    } else {
      _purchaseController.add(IapPurchaseEvent(productId: productId, status: IapPurchaseStatus.canceled));
      return false;
    }
  }

  @override
  Future<void> restorePurchases() async {
    _purchaseController.add(const IapPurchaseEvent(productId: 'vihome_premium_monthly', status: IapPurchaseStatus.restored));
  }

  @override
  Stream<IapPurchaseEvent> get purchaseStream => _purchaseController.stream;

  void dispose() {
    _purchaseController.close();
  }
}

void main() {
  group('Decoupled Service Interfaces & Fakes [RF-11.1, RF-12.1, RNF-05]', () {
    late FakeRealtimeService fakeRealtime;
    late FakeIapService fakeIap;

    setUp(() {
      fakeRealtime = FakeRealtimeService();
      fakeIap = FakeIapService();
    });

    tearDown(() {
      fakeRealtime.dispose();
      fakeIap.dispose();
    });

    test('IRealtimeService emits events without throwing', () async {
      expect(fakeRealtime.isConnected, isTrue);

      final stream = fakeRealtime.subscribeToTable<Application>(
        table: 'solicitudes',
        filterColumn: 'arrendador_id',
        filterValue: 'usr_landlord',
        fromJson: (json) => ApplicationFixtures.pendingApplication,
      );

      expectLater(
        stream,
        emits(predicate<Application>(
            (app) => app.id == ApplicationFixtures.pendingApplication.id)),
      );
      fakeRealtime.emitApplication(ApplicationFixtures.pendingApplication);
    });

    test('IIapService processes buy and restore purchase events', () async {
      final isAvail = await fakeIap.isAvailable();
      expect(isAvail, isTrue);

      expectLater(
        fakeIap.purchaseStream,
        emits(predicate<IapPurchaseEvent>((e) => e.status == IapPurchaseStatus.purchased)),
      );

      final bought = await fakeIap.buyProduct('vihome_premium_monthly');
      expect(bought, isTrue);
    });
  });
}
