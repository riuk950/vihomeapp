import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:vihomeapp/domain/services/i_iap_service.dart';

/// Implementación de `IIapService` envolviendo el plugin `in_app_purchase` [RF-12]
class InAppPurchaseService implements IIapService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final StreamController<IapPurchaseEvent> _purchaseController =
      StreamController<IapPurchaseEvent>.broadcast();
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  InAppPurchaseService() {
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) {
        _purchaseController.add(
          IapPurchaseEvent(
            productId: '',
            status: IapPurchaseStatus.error,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      IapPurchaseStatus status;
      switch (purchase.status) {
        case PurchaseStatus.pending:
          status = IapPurchaseStatus.pending;
          break;
        case PurchaseStatus.purchased:
          status = IapPurchaseStatus.purchased;
          break;
        case PurchaseStatus.canceled:
          status = IapPurchaseStatus.canceled;
          break;
        case PurchaseStatus.error:
          status = IapPurchaseStatus.error;
          break;
        case PurchaseStatus.restored:
          status = IapPurchaseStatus.restored;
          break;
      }

      _purchaseController.add(
        IapPurchaseEvent(
          productId: purchase.productID,
          status: status,
          errorMessage: purchase.error?.message,
        ),
      );

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      return await _iap.isAvailable();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<IapProduct>> getProducts(Set<String> productIds) async {
    try {
      final response = await _iap.queryProductDetails(productIds);
      return response.productDetails
          .map((p) => IapProduct(id: p.id, title: p.title, price: p.price))
          .toList();
    } catch (e) {
      debugPrint('[InAppPurchaseService] Error fetching products: $e');
      return [];
    }
  }

  @override
  Future<bool> buyProduct(String productId) async {
    try {
      final response = await _iap.queryProductDetails({productId});
      if (response.productDetails.isEmpty) return false;
      final product = response.productDetails.first;

      PurchaseParam purchaseParam;
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidDetails = product as GooglePlayProductDetails;
        final offerToken = androidDetails.offerToken;
        if (offerToken != null) {
          purchaseParam = GooglePlayPurchaseParam(
            productDetails: product,
            offerToken: offerToken,
          );
        } else {
          purchaseParam = PurchaseParam(productDetails: product);
        }
      } else {
        purchaseParam = PurchaseParam(productDetails: product);
      }

      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('[InAppPurchaseService] Error buying product: $e');
      return false;
    }
  }

  @override
  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('[InAppPurchaseService] Error restoring purchases: $e');
    }
  }

  @override
  Stream<IapPurchaseEvent> get purchaseStream => _purchaseController.stream;

  void dispose() {
    _subscription?.cancel();
    _purchaseController.close();
  }
}
