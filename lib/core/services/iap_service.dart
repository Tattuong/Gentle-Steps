import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../constants/iap_constants.dart';

typedef PurchaseHandler = Future<void> Function(PurchaseDetails purchase);

class IapService {
  IapService._();
  static final IapService instance = IapService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  PurchaseHandler? _handler;
  bool _available = false;

  bool get isAvailable => _available;
  Map<String, ProductDetails> _products = {};

  Map<String, ProductDetails> get products => Map.unmodifiable(_products);

  Future<bool> init(PurchaseHandler handler) async {
    _handler = handler;
    _available = await _iap.isAvailable();
    if (!_available) return false;

    _sub ??= _iap.purchaseStream.listen(_onPurchases, onError: (e) => debugPrint('IAP stream error: $e'));
    return true;
  }

  Future<void> loadProducts() async {
    if (!_available) return;
    final response = await _iap.queryProductDetails(IapProducts.all.toSet());
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('IAP products not found: ${response.notFoundIDs}');
    }
    _products = {for (final p in response.productDetails) p.id: p};
  }

  ProductDetails? product(String id) => _products[id];

  Future<bool> buyConsumable(String productId) async {
    final product = _products[productId];
    if (product == null) return false;
    final param = PurchaseParam(productDetails: product);
    return _iap.buyConsumable(purchaseParam: param, autoConsume: true);
  }

  Future<bool> buyNonConsumable(String productId) async {
    final product = _products[productId];
    if (product == null) return false;
    final param = PurchaseParam(productDetails: product);
    return _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restorePurchases() async {
    if (!_available) return;
    await _iap.restorePurchases();
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) continue;

      if (purchase.status == PurchaseStatus.error) {
        debugPrint('IAP error: ${purchase.error}');
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        await _handler?.call(purchase);
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
