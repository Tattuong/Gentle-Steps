import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../core/constants/iap_constants.dart';
import '../core/services/iap_config_service.dart';
import '../core/services/iap_service.dart';
import '../core/services/storage_service.dart';

class ShopProvider extends ChangeNotifier {
  static const _coinsKey = 'shop_coins';
  static const _ownedKey = 'shop_owned_items';
  static const _removeAdsKey = 'shop_remove_ads';
  static const _activeThemeKey = 'shop_active_theme';
  static const _activeSkinKey = 'shop_active_skin';
  static const _activeBgKey = 'shop_active_bg';
  static const _rewardDateKey = 'shop_reward_date';
  static const _goalRewardKey = 'shop_goal_reward_date';
  static const _stepsRewardKey = 'shop_steps_reward_tier';

  int _coins = 0;
  Set<String> _owned = {};
  bool _removeAds = false;
  String? _activeTheme;
  String? _activeSkin;
  String? _activeBg;

  bool _iapEnabled = false;
  bool _configLoaded = false;
  bool _networkError = false;
  bool _purchasing = false;
  String? _statusMessage;

  int get coins => _coins;
  /// Google Billing — mua sao bằng tiền. `disable=1` trên API → false.
  bool get iapEnabled => _iapEnabled;
  bool get starPurchaseEnabled => _iapEnabled;
  bool get configLoaded => _configLoaded;
  bool get networkError => _networkError;
  bool get purchasing => _purchasing;
  bool get removeAds => _removeAds;
  String? get activeTheme => _activeTheme;
  String? get activeSkin => _activeSkin;
  String? get activeBackground => _activeBg;
  String? get statusMessage => _statusMessage;

  LinearGradient? get homeGradient => ShopVisuals.backgroundGradient(_activeBg);
  Color get accentOverride => ShopVisuals.accentColor(_activeTheme);

  ShopProvider() {
    _loadLocal();
  }

  Future<void> init() async {
    final config = await IapConfigService.instance.fetch();
    _iapEnabled = config.iapEnabled;
    _networkError = config.networkError;
    _configLoaded = true;

    // Dev: API lỗi/404 vẫn mở billing để test local.
    if (kDebugMode && !_iapEnabled && config.networkError) {
      _iapEnabled = true;
      debugPrint('IAP: debug — billing enabled (API unreachable)');
    }

    if (_iapEnabled) {
      await IapService.instance.init(_handlePurchase);
      await IapService.instance.loadProducts();
    }

    notifyListeners();
  }

  Future<void> refreshConfig() async => init();

  Future<void> _loadLocal() async {
    _coins = await StorageService.instance.getInt(_coinsKey) ?? 0;
    _removeAds = await StorageService.instance.getBool(_removeAdsKey) ?? false;

    final ownedRaw = await StorageService.instance.getString(_ownedKey);
    if (ownedRaw != null) {
      final list = jsonDecode(ownedRaw) as List<dynamic>;
      _owned = list.map((e) => e as String).toSet();
    }

    _activeTheme = await StorageService.instance.getString(_activeThemeKey);
    _activeSkin = await StorageService.instance.getString(_activeSkinKey);
    _activeBg = await StorageService.instance.getString(_activeBgKey);

    if (_removeAds) _owned.add('remove_ads_coins');
    notifyListeners();
  }

  bool owns(String itemId) => _owned.contains(itemId) || (itemId == 'remove_ads_coins' && _removeAds);

  bool isEquipped(String itemId, ShopItemCategory category) => switch (category) {
        ShopItemCategory.theme => _activeTheme == itemId,
        ShopItemCategory.skin => _activeSkin == itemId,
        ShopItemCategory.background => _activeBg == itemId,
        ShopItemCategory.feature => false,
      };

  Future<void> syncDailyRewards({
    required int todaySteps,
    required int goal,
    required bool goalReached,
  }) async {
    final today = _dateKey(DateTime.now());
    final rewardDate = await StorageService.instance.getString(_rewardDateKey);
    if (rewardDate != today) {
      await StorageService.instance.saveString(_rewardDateKey, today);
      await StorageService.instance.remove(_goalRewardKey);
      await StorageService.instance.remove(_stepsRewardKey);
    }

    if (goalReached) {
      final goalRewarded = await StorageService.instance.getString(_goalRewardKey);
      if (goalRewarded != today) {
        await _addCoins(15, persist: true);
        await StorageService.instance.saveString(_goalRewardKey, today);
        _statusMessage = '+15 ⭐ goal bonus';
        notifyListeners();
      }
    }

    final tier = (todaySteps / 5000).floor().clamp(0, 3);
    final rewardedTier = await StorageService.instance.getInt(_stepsRewardKey) ?? 0;
    if (tier > rewardedTier) {
      final bonus = (tier - rewardedTier) * 5;
      await _addCoins(bonus, persist: true);
      await StorageService.instance.saveInt(_stepsRewardKey, tier);
      _statusMessage = '+$bonus ⭐ walking bonus';
      notifyListeners();
    }
  }

  Future<bool> buyWithCoins(String itemId) async {
    final item = ShopCatalog.find(itemId);
    if (item == null) return false;
    if (owns(itemId)) {
      await equip(item);
      return true;
    }
    if (_coins < item.coinPrice) return false;

    _coins -= item.coinPrice;
    _owned.add(itemId);
    if (item.category == ShopItemCategory.feature && itemId == 'remove_ads_coins') {
      _removeAds = true;
      await StorageService.instance.saveBool(_removeAdsKey, true);
    }
    await _persist();
    await equip(item);
    notifyListeners();
    return true;
  }

  Future<void> equip(ShopItemDef item) async {
    if (!owns(item.id) && item.coinPrice > 0) return;
    switch (item.category) {
      case ShopItemCategory.theme:
        _activeTheme = item.id;
        await StorageService.instance.saveString(_activeThemeKey, item.id);
      case ShopItemCategory.skin:
        _activeSkin = item.id;
        await StorageService.instance.saveString(_activeSkinKey, item.id);
      case ShopItemCategory.background:
        _activeBg = item.id;
        await StorageService.instance.saveString(_activeBgKey, item.id);
      case ShopItemCategory.feature:
        break;
    }
    notifyListeners();
  }

  Future<void> clearEquip(ShopItemCategory category) async {
    switch (category) {
      case ShopItemCategory.theme:
        _activeTheme = null;
        await StorageService.instance.remove(_activeThemeKey);
      case ShopItemCategory.skin:
        _activeSkin = null;
        await StorageService.instance.remove(_activeSkinKey);
      case ShopItemCategory.background:
        _activeBg = null;
        await StorageService.instance.remove(_activeBgKey);
      case ShopItemCategory.feature:
        break;
    }
    notifyListeners();
  }

  Future<bool> purchaseProduct(String productId) async {
    if (!_iapEnabled || _purchasing) return false;
    _purchasing = true;
    _statusMessage = null;
    notifyListeners();

    final ok = IapProducts.consumables.contains(productId)
        ? await IapService.instance.buyConsumable(productId)
        : await IapService.instance.buyNonConsumable(productId);

    if (!ok) {
      _purchasing = false;
      _statusMessage = 'purchase_failed';
      notifyListeners();
    }
    return ok;
  }

  Future<void> restorePurchases() async {
    if (!_iapEnabled) return;
    _purchasing = true;
    notifyListeners();
    await IapService.instance.restorePurchases();
    _purchasing = false;
    notifyListeners();
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    final id = purchase.productID;

    if (IapProducts.coinAmounts.containsKey(id)) {
      await _addCoins(IapProducts.coinAmounts[id]!, persist: true);
      _statusMessage = 'purchase_success';
    } else if (id == IapProducts.removeAds) {
      _removeAds = true;
      _owned.add('remove_ads_coins');
      await StorageService.instance.saveBool(_removeAdsKey, true);
      await _persist();
      _statusMessage = 'purchase_success';
    }

    _purchasing = false;
    notifyListeners();
  }

  Future<void> _addCoins(int amount, {required bool persist}) async {
    _coins += amount;
    if (persist) await StorageService.instance.saveInt(_coinsKey, _coins);
  }

  Future<void> _persist() async {
    await StorageService.instance.saveInt(_coinsKey, _coins);
    await StorageService.instance.saveString(_ownedKey, jsonEncode(_owned.toList()));
  }

  void clearStatus() {
    _statusMessage = null;
    notifyListeners();
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    IapService.instance.dispose();
    super.dispose();
  }
}
