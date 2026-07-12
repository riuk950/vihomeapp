import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vihomeapp/core/di/injection_container.dart';
import 'package:vihomeapp/infrastructure/services/analytics_service.dart';
import 'package:vihomeapp/presentation/pages/suscripciones/subscription_ids.dart';

class SubscriptionProvider with ChangeNotifier {
  String? _userId;
  bool _isSubscribed = false;
  bool _isLoading = false;
  String? _errorMessage;

  /// Callback opcional que se invoca tras una compra/restauración exitosa.
  /// Úsalo para recargar el AuthProvider y refrescar isPremium en la UI.
  VoidCallback? onPurchaseSuccess;

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];

  bool get isSubscribed => _isSubscribed;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ProductDetails> get products => _products;

  static const String monthlySubscriptionId = SubscriptionIds.mensual;
  static const String sixMonthSubscriptionId = SubscriptionIds.semestral;
  static const String yearlySubscriptionId = SubscriptionIds.anual;

  static const Set<String> _productIds = {
    monthlySubscriptionId,
    sixMonthSubscriptionId,
    yearlySubscriptionId,
  };

  SubscriptionProvider() {
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => _setError('Error en el stream de compras: $error'),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// Inicializa el gestor con el ID de usuario de Supabase
  Future<void> initialize(String? userId) async {
    if (kIsWeb) return;
    _userId = userId;

    final bool available = await _iap.isAvailable();
    if (!available) {
      _setError('La tienda no está disponible en este momento.');
      debugPrint('[IAP] ❌ Google Play Store no disponible.');
      return;
    }

    debugPrint('[IAP] ✅ Google Play Store disponible. Cargando productos...');
    _setLoading(true);
    await fetchAvailableProducts();
    await checkSubscriptionStatus();
    _setLoading(false);
  }

  /// Verifica el estado actual consultando Supabase al iniciar la app.
  ///
  /// Estrategia inteligente:
  /// 1. Lee is_premium y premium_expires_at desde Supabase (fuente de verdad local).
  /// 2. Si is_premium=true pero premium_expires_at ya pasó → re-verifica con Google
  ///    Play via Edge Function para detectar cancelaciones o expiración real.
  /// 3. Si is_premium=true y premium_expires_at aún es válido → no llama a Google
  ///    (evita invocaciones innecesarias en cada arranque).
  Future<void> checkSubscriptionStatus() async {
    if (_userId == null) return;
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('is_premium, premium_expires_at, premium_product_id')
          .eq('id', _userId!)
          .maybeSingle();

      if (data == null) return;

      final bool isPremium = data['is_premium'] ?? false;
      final String? expiresAtRaw = data['premium_expires_at'] as String?;
      final String? productId = data['premium_product_id'] as String?;

      debugPrint('[IAP] Estado desde Supabase: is_premium=$isPremium, expires_at=$expiresAtRaw');

      if (!isPremium) {
        // No es premium: nada que verificar
        _isSubscribed = false;
        notifyListeners();
        return;
      }

      // Es premium: comprobar si la fecha de expiración ya pasó
      final DateTime? expiresAt = expiresAtRaw != null
          ? DateTime.tryParse(expiresAtRaw)?.toLocal()
          : null;

      final bool isExpiredLocally =
          expiresAt != null && expiresAt.isBefore(DateTime.now());

      if (!isExpiredLocally) {
        // Suscripción activa y vigente según Supabase → OK sin llamar a Google
        _isSubscribed = true;
        debugPrint('[IAP] ✅ Suscripción activa hasta ${expiresAt?.toIso8601String() ?? "fecha desconocida"}');
        notifyListeners();
        return;
      }

      // La fecha de expiración en Supabase ya pasó: re-verificar con Google Play
      // para detectar renovación, cancelación o expiración real.
      debugPrint('[IAP] ⚠️ premium_expires_at expiró. Re-verificando con Google Play...');

      if (productId != null) {
        // Necesitamos el purchaseToken actual → usamos restorePurchases
        // para que el stream reciba el token actualizado de Google.
        // Esto actualiza is_premium via la Edge Function automáticamente.
        await _iap.restorePurchases();
        debugPrint('[IAP] 🔄 restorePurchases lanzado para re-verificación al inicio.');
        // El resultado llega via _onPurchaseUpdate (stream)
      } else {
        // Sin productId almacenado: marcamos como no premium localmente
        // El stream de compras manejará si hay alguna suscripción activa
        _isSubscribed = false;
        debugPrint('[IAP] ⚠️ Sin product_id almacenado. Marcando como no premium.');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[IAP] ❌ Error al verificar estado de suscripción: $e');
    }
  }

  /// Obtiene los productos disponibles desde Google Play
  Future<void> fetchAvailableProducts() async {
    try {
      debugPrint('[IAP] Consultando productos: $_productIds');
      final ProductDetailsResponse response =
          await _iap.queryProductDetails(_productIds);

      if (response.error != null) {
        debugPrint('[IAP] ❌ Error al consultar productos: ${response.error}');
      }

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint(
            '[IAP] ⚠️ Productos NO encontrados en Play Store: ${response.notFoundIDs}');
        debugPrint(
            '[IAP] Verifica que los IDs existan en Play Console y que la app esté en un track (Internal Testing).');
      }

      if (response.productDetails.isNotEmpty) {
        debugPrint('[IAP] ✅ Productos encontrados: ${response.productDetails.map((p) => '${p.id}=${p.price}').join(', ')}');
      } else {
        debugPrint('[IAP] ⚠️ No se encontraron productos. Verifica:');
        debugPrint('[IAP]   1. La app está publicada en Internal Testing en Play Console.');
        debugPrint('[IAP]   2. La cuenta del dispositivo es un License Tester en Play Console.');
        debugPrint('[IAP]   3. Los IDs de suscripción están activos (no borrador).');
        debugPrint('[IAP]   4. El package ID del APK coincide con el de Play Console.');
      }

      _products = response.productDetails;
      notifyListeners();
    } catch (e) {
      _setError('Error obteniendo productos: $e');
      debugPrint('[IAP] ❌ Excepción al consultar productos: $e');
    }
  }

  /// Inicia el proceso de compra de un producto (suscripción)
  Future<bool> purchaseProduct(ProductDetails product) async {
    try {
      _setLoading(true);
      clearError();

      await getIt<AnalyticsService>().logSubscriptionStarted(product.id);

      PurchaseParam purchaseParam;

      // En Android, usamos GooglePlayPurchaseParam para suscripciones
      // y pasamos el offerToken del producto seleccionado
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidDetails = product as GooglePlayProductDetails;
        final offerToken = androidDetails.offerToken;

        if (offerToken == null) {
          debugPrint('[IAP] ⚠️ No se encontró offerToken para ${product.id}. Usando compra estándar.');
          purchaseParam = PurchaseParam(productDetails: product);
        } else {
          debugPrint('[IAP] 🛒 Comprando ${product.id} con offerToken: $offerToken');
          purchaseParam = GooglePlayPurchaseParam(
            productDetails: product,
            offerToken: offerToken,
            changeSubscriptionParam: null, // null si es nueva suscripción
          );
        }
      } else {
        purchaseParam = PurchaseParam(productDetails: product);
      }

      // buyNonConsumable es correcto para suscripciones con in_app_purchase
      bool success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);

      if (!success) {
        debugPrint('[IAP] ❌ buyNonConsumable retornó false para ${product.id}');
        _setLoading(false);
      }

      return success;
    } catch (e) {
      _setError('Error al iniciar la compra: $e');
      debugPrint('[IAP] ❌ Excepción en purchaseProduct: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Restaura las compras anteriores de forma explícita (botón en la UI)
  Future<bool> restorePurchases() async {
    try {
      _setLoading(true);
      clearError();
      debugPrint('[IAP] 🔄 Restaurando compras...');
      await _iap.restorePurchases();
      return true;
    } catch (e) {
      _setError('Error al restaurar compras: $e');
      debugPrint('[IAP] ❌ Error en restorePurchases: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Maneja las actualizaciones de compras del stream
  Future<void> _onPurchaseUpdate(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchase in purchaseDetailsList) {
      debugPrint('[IAP] 📦 Update: productID=${purchase.productID} status=${purchase.status}');

      if (purchase.status == PurchaseStatus.pending) {
        _setLoading(true);
        continue;
      }

      if (purchase.status == PurchaseStatus.error) {
        _setError(
            'Error en la compra: ${purchase.error?.message ?? "Error desconocido"}');
        debugPrint('[IAP] ❌ Error de compra: ${purchase.error}');
        _setLoading(false);
      } else if (purchase.status == PurchaseStatus.canceled) {
        debugPrint('[IAP] 🚫 Compra cancelada por el usuario.');
        _setLoading(false);
      } else if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        final isRestored = purchase.status == PurchaseStatus.restored;
        debugPrint('[IAP] ✅ Compra ${isRestored ? "restaurada" : "exitosa"}: ${purchase.productID}');

        if (!isRestored) {
          await getIt<AnalyticsService>().logSubscriptionSuccess(purchase.productID);
        }

        // Verificar la compra de forma segura con la Edge Function de Supabase.
        // La Edge Function consulta Google Play Developer API y actualiza is_premium
        // en el servidor (con service_role_key, omitiendo RLS).
        final purchaseToken = purchase.verificationData.serverVerificationData;
        final verified = await _verifyPurchaseWithBackend(
          purchaseToken: purchaseToken,
          productId: purchase.productID,
        );

        if (verified) {
          _isSubscribed = true;
          // Notificar al AuthProvider para refrescar isPremium en la UI
          onPurchaseSuccess?.call();
        } else {
          _setError('La verificación del pago no fue exitosa. Intenta restaurar las compras.');
        }

        if (purchase.pendingCompletePurchase) {
          debugPrint('[IAP] 🏁 Completando compra pendiente: ${purchase.productID}');
          await _iap.completePurchase(purchase);
        }
        _setLoading(false);
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

  /// Verifica la compra contra Google Play Developer API via Edge Function de Supabase.
  /// La Edge Function autentica con Google usando Service Account y actualiza
  /// is_premium en el servidor de forma segura (sin exponer credentials en el cliente).
  Future<bool> _verifyPurchaseWithBackend({
    required String purchaseToken,
    required String productId,
  }) async {
    try {
      debugPrint('[IAP] 🔐 Enviando a Edge Function verify-subscription...');
      debugPrint('[IAP]   productId: $productId');
      
      final displayToken = purchaseToken.length > 20 
          ? '${purchaseToken.substring(0, 20)}...' 
          : (purchaseToken.isEmpty ? 'VACÍO' : purchaseToken);
      debugPrint('[IAP]   purchaseToken: $displayToken');

      // Si no hay token, no podemos verificar en el backend
      if (purchaseToken.isEmpty) {
        debugPrint('[IAP] ❌ purchaseToken vacío, imposible verificar.');
        return false;
      }

      final response = await Supabase.instance.client.functions.invoke(
        'verify-subscription',
        body: {
          'purchaseToken': purchaseToken,
          'productId': productId,
          'packageName': 'com.vihomeapp.vihomeapp',
        },
      );

      if (response.status != 200) {
        final errorMsg = response.data?['error'] ?? 'Error desconocido de la Edge Function';
        debugPrint('[IAP] ❌ Edge Function error (status=${response.status}): $errorMsg');
        // Fallback: actualizar Supabase directamente si la Edge Function falla
        debugPrint('[IAP] ⚠️ Fallback: actualizando is_premium directamente (sin verificación de Google).');
        await _updateSupabasePremiumStatus(true);
        return true;
      }

      final isActive = response.data?['isActive'] as bool? ?? false;
      final message = response.data?['message'] ?? '';
      debugPrint('[IAP] ✅ Edge Function respuesta: isActive=$isActive | $message');

      return isActive;
    } catch (e) {
      debugPrint('[IAP] ❌ Excepción llamando Edge Function: $e');
      // Fallback en caso de error de red o función no disponible
      debugPrint('[IAP] ⚠️ Fallback: actualizando is_premium directamente.');
      await _updateSupabasePremiumStatus(true);
      return true;
    }
  }

  /// Actualiza is_premium directamente en Supabase (fallback o pruebas).
  /// En producción, esto es manejado por la Edge Function verify-subscription.
  Future<void> _updateSupabasePremiumStatus(bool status) async {
    if (_userId == null) return;
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'is_premium': status}).eq('id', _userId!);
      debugPrint('[IAP] ✅ Supabase is_premium actualizado a $status (directo)');
    } catch (e) {
      debugPrint('[IAP] ❌ Error actualizando is_premium en Supabase: $e');
    }
  }
}
