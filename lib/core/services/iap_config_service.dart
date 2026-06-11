import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/iap_constants.dart';
import 'storage_service.dart';

class IapRemoteConfig {
  final bool iapEnabled;
  final bool fromCache;
  final bool networkError;
  final String? message;

  const IapRemoteConfig({
    required this.iapEnabled,
    this.fromCache = false,
    this.networkError = false,
    this.message,
  });
}

class IapConfigService {
  IapConfigService._();
  static final IapConfigService instance = IapConfigService._();

  static const _cacheKey = 'iap_config_cache';
  static const _cacheDisableKey = 'iap_config_disable';

  /// `disable == 0` → mua sao bằng tiền bật. `disable == 1` → chỉ tắt Google Billing, shop vẫn dùng sao kiếm được.
  Future<IapRemoteConfig> fetch() async {
    try {
      final response = await http.get(Uri.parse(iapConfigUrl)).timeout(iapConfigTimeout);
      if (response.statusCode != 200) {
        return _fallback(networkError: true, message: 'HTTP ${response.statusCode}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final disable = _parseDisable(json['disable']);
      final enabled = disable == 0;

      await StorageService.instance.saveInt(_cacheDisableKey, disable);
      await StorageService.instance.saveString(_cacheKey, response.body);

      return IapRemoteConfig(iapEnabled: enabled, message: json['msg'] as String?);
    } catch (e) {
      debugPrint('IAP config fetch failed: $e');
      return _fallback(networkError: true, message: e.toString());
    }
  }

  Future<IapRemoteConfig> _fallback({required bool networkError, String? message}) async {
    final cachedDisable = await StorageService.instance.getInt(_cacheDisableKey);
    if (cachedDisable != null) {
      return IapRemoteConfig(
        iapEnabled: cachedDisable == 0,
        fromCache: true,
        networkError: networkError,
        message: message,
      );
    }
    return IapRemoteConfig(
      iapEnabled: false,
      fromCache: false,
      networkError: networkError,
      message: message,
    );
  }

  int _parseDisable(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 1;
    return 1;
  }
}
