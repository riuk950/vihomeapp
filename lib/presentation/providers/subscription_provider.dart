import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionProvider with ChangeNotifier {
  String? _userId;
  bool _isSubscribed = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];

  bool get isSubscribed => _isSubscribed;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ProductDetails> get products => _products;

  /// IDs de los productos configurados en Play Store y App Store
  static const Set<String> _productIds = {
    'premium_subscription', // Cambiar por los IDs reales de la tienda
  };

  SubscriptionProvider() {
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription.cancel(),
      onError: (error) => _setError('Error en el stream de compras: $error'),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  /// Inicializa el gestor con el ID de usuario de Supabase
  Future<void> initialize(String? userId) async {
    if (kIsWeb) return;
    _userId = userId;
    
    final bool available = await _iap.isAvailable();
    if (!available) {
      _setError('La tienda no está disponible en este momento.');
      return;
    }

    await fetchAvailableProducts();
    await checkSubscriptionStatus();
  }

  /// Verifica el estado actual de la suscripción restaurando compras
  Future<void> checkSubscriptionStatus() async {
    try {
      _setLoading(true);
      clearError();
      
      // En in_app_purchase, restaurar compras es la forma de verificar suscripciones activas
      // aunque en Android es mejor verificar el estado guardado o usar el stream.
      await _iap.restorePurchases();
      
      _setLoading(false);
    } catch (e) {
      _setError('Error al verificar suscripción: $e');
      _setLoading(false);
    }
  }

  /// Obtiene los productos disponibles desde las tiendas
  Future<void> fetchAvailableProducts() async {
    try {
      final ProductDetailsResponse response = await _iap.queryProductDetails(_productIds);
      
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Productos no encontrados: ${response.notFoundIDs}');
      }
      
      _products = response.productDetails;
      notifyListeners();
    } catch (e) {
      _setError('Error obteniendo productos: $e');
    }
  }

  /// Inicia el proceso de compra de un producto
  Future<bool> purchaseProduct(ProductDetails product) async {
    try {
      _setLoading(true);
      clearError();

      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      
      // Para suscripciones usamos buyNonConsumable (se maneja igual en IAP plugin para subs)
      bool success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      
      if (!success) {
        _setLoading(false);
      }
      
      return success;
    } catch (e) {
      _setError('Error al iniciar la compra: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Restaura las compras anteriores
  Future<bool> restorePurchases() async {
    try {
      _setLoading(true);
      clearError();
      await _iap.restorePurchases();
      return true;
    } catch (e) {
      _setError('Error al restaurar compras: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Maneja las actualizaciones de compras del stream
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.pending) {
        _setLoading(true);
      } else {
        if (purchase.status == PurchaseStatus.error) {
          _setError('Error en la compra: ${purchase.error}');
          _setLoading(false);
        } else if (purchase.status == PurchaseStatus.purchased || 
                   purchase.status == PurchaseStatus.restored) {
          
          // Validar la compra (Idealmente en el servidor)
          // Si es válida, marcar como suscrito
          _isSubscribed = true;
          await _updateSupabasePremiumStatus(true);
          
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          _setLoading(false);
        } else if (purchase.status == PurchaseStatus.canceled) {
          _setLoading(false);
        }
      }
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Sincroniza el estado is_premium directamente en Supabase
  Future<void> _updateSupabasePremiumStatus(bool status) async {
    if (_userId == null) return;
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'is_premium': status})
          .eq('id', _userId!);
    } catch (e) {
      debugPrint('Error actualizando is_premium en Supabase: $e');
    }
  }
}
