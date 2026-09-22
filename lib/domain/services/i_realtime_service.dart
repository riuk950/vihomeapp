/// Contrato para la infraestructura de eventos y reactividad en tiempo real [RF-11]
abstract class IRealtimeService {
  /// Indica si la conexión de websocket/canal está activa
  bool get isConnected;

  /// Flujo con los cambios de estado de conectividad en tiempo real
  Stream<bool> get connectionStatusStream;

  /// Suscribe a cambios en una tabla filtrada por columna y valor
  Stream<T> subscribeToTable<T>({
    required String table,
    required String filterColumn,
    required dynamic filterValue,
    required T Function(Map<String, dynamic> json) fromJson,
  });

  /// Cancela la suscripción a un canal específico
  Future<void> unsubscribe(String channel);

  /// Cancela todas las suscripciones activas
  Future<void> unsubscribeAll();
}
