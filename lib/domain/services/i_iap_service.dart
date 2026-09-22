/// Estado de un evento de compra dentro de la aplicación
enum IapPurchaseStatus {
  pending,
  purchased,
  canceled,
  error,
  restored,
}

/// Representación desacoplada de un producto de la tienda
class IapProduct {
  final String id;
  final String title;
  final String price;

  const IapProduct({
    required this.id,
    required this.title,
    required this.price,
  });
}

/// Evento de compra emitido por la plataforma
class IapPurchaseEvent {
  final String productId;
  final IapPurchaseStatus status;
  final String? errorMessage;

  const IapPurchaseEvent({
    required this.productId,
    required this.status,
    this.errorMessage,
  });
}

/// Contrato para pagos dentro de la app (In-App Purchases) y restauración [RF-12]
abstract class IIapService {
  /// Verifica si la tienda de aplicaciones está disponible en el dispositivo
  Future<bool> isAvailable();

  /// Obtiene los detalles de los productos por sus identificadores
  Future<List<IapProduct>> getProducts(Set<String> productIds);

  /// Inicia el flujo de compra para un identificador de producto
  Future<bool> buyProduct(String productId);

  /// Solicita la restauración de compras previas del usuario
  Future<void> restorePurchases();

  /// Stream reactivo de eventos de compra
  Stream<IapPurchaseEvent> get purchaseStream;
}
