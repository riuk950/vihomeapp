import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vihomeapp/domain/services/i_realtime_service.dart';
import 'package:vihomeapp/infrastructure/services/supabase_service.dart';

/// Implementación de `IRealtimeService` conectada a Supabase Realtime [RF-11]
class SupabaseRealtimeService implements IRealtimeService {
  final Map<String, RealtimeChannel> _activeChannels = {};
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();
  bool _isConnected = true;

  @override
  bool get isConnected => _isConnected;

  @override
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  @override
  Stream<T> subscribeToTable<T>({
    required String table,
    required String filterColumn,
    required dynamic filterValue,
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    final channelKey = '$table:$filterColumn=$filterValue';
    final controller = StreamController<T>.broadcast();

    try {
      final client = SupabaseService.instance.client;
      final channel = client.channel('public:$channelKey');

      channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: table,
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: filterColumn,
          value: filterValue,
        ),
        callback: (payload) {
          try {
            final record = payload.newRecord;
            if (record.isNotEmpty) {
              controller.add(fromJson(record));
            }
          } catch (e) {
            debugPrint('[Realtime] Error deserializando payload: $e');
          }
        },
      ).subscribe((status, [error]) {
        if (status == RealtimeSubscribeStatus.subscribed) {
          _isConnected = true;
          _connectionStatusController.add(true);
        } else if (status == RealtimeSubscribeStatus.closed ||
            status == RealtimeSubscribeStatus.channelError) {
          _isConnected = false;
          _connectionStatusController.add(false);
        }
      });

      _activeChannels[channelKey] = channel;
    } catch (e) {
      debugPrint('[Realtime] Error inicializando canal: $e');
    }

    controller.onCancel = () {
      unsubscribe(channelKey);
    };

    return controller.stream;
  }

  @override
  Future<void> unsubscribe(String channel) async {
    final chan = _activeChannels.remove(channel);
    if (chan != null) {
      await chan.unsubscribe();
    }
  }

  @override
  Future<void> unsubscribeAll() async {
    for (final chan in _activeChannels.values) {
      await chan.unsubscribe();
    }
    _activeChannels.clear();
  }

  void dispose() {
    unsubscribeAll();
    _connectionStatusController.close();
  }
}
