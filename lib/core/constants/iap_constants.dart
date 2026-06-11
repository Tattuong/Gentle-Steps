import 'package:flutter/material.dart';

/// Remote IAP config — each app has its own JSON on the management server.
const iapConfigUrl = 'https://api2.blwsmartware.net/T107.json';
const iapConfigTimeout = Duration(seconds: 8);

class IapProducts {
  IapProducts._();

  static const prefix = 'gs';

  static const pack1 = 'gs_pack_1';
  static const pack2 = 'gs_pack_2';
  static const pack3 = 'gs_pack_3';
  static const pack4 = 'gs_pack_4';
  static const pack5 = 'gs_pack_5';
  static const pack6 = 'gs_pack_6';
  static const pack7 = 'gs_pack_7';
  static const pack8 = 'gs_pack_8';
  static const pack9 = 'gs_pack_9';
  static const pack10 = 'gs_pack_10';
  static const removeAds = 'gs_remove_ads';

  static const consumables = [
    pack1, pack2, pack3, pack4, pack5,
    pack6, pack7, pack8, pack9, pack10,
  ];
  static const nonConsumables = [removeAds];
  static const all = [...consumables, ...nonConsumables];

  static String packId(int n) => '${prefix}_pack_$n';

  static const coinAmounts = {
    pack1: 50,
    pack2: 100,
    pack3: 200,
    pack4: 350,
    pack5: 500,
    pack6: 650,
    pack7: 850,
    pack8: 1100,
    pack9: 1400,
    pack10: 2000,
  };
}

enum ShopItemCategory { theme, skin, background, feature }

class ShopItemDef {
  final String id;
  final ShopItemCategory category;
  final int coinPrice;
  final String nameKey;
  final String descKey;
  final IconData icon;
  final Color previewColor;

  const ShopItemDef({
    required this.id,
    required this.category,
    required this.coinPrice,
    required this.nameKey,
    required this.descKey,
    required this.icon,
    required this.previewColor,
  });
}

class ShopCatalog {
  ShopCatalog._();

  static const items = [
    ShopItemDef(
      id: 'theme_ocean',
      category: ShopItemCategory.theme,
      coinPrice: 80,
      nameKey: 'shopThemeOcean',
      descKey: 'shopThemeOceanDesc',
      icon: Icons.water_rounded,
      previewColor: Color(0xFF7EC8E3),
    ),
    ShopItemDef(
      id: 'theme_sunset',
      category: ShopItemCategory.theme,
      coinPrice: 80,
      nameKey: 'shopThemeSunset',
      descKey: 'shopThemeSunsetDesc',
      icon: Icons.wb_sunny_rounded,
      previewColor: Color(0xFFFFB88C),
    ),
    ShopItemDef(
      id: 'theme_forest',
      category: ShopItemCategory.theme,
      coinPrice: 80,
      nameKey: 'shopThemeForest',
      descKey: 'shopThemeForestDesc',
      icon: Icons.park_rounded,
      previewColor: Color(0xFF5BB8A8),
    ),
    ShopItemDef(
      id: 'skin_gold',
      category: ShopItemCategory.skin,
      coinPrice: 100,
      nameKey: 'shopSkinGold',
      descKey: 'shopSkinGoldDesc',
      icon: Icons.auto_awesome_rounded,
      previewColor: Color(0xFFFFD700),
    ),
    ShopItemDef(
      id: 'skin_coral',
      category: ShopItemCategory.skin,
      coinPrice: 100,
      nameKey: 'shopSkinCoral',
      descKey: 'shopSkinCoralDesc',
      icon: Icons.favorite_rounded,
      previewColor: Color(0xFFFF6B8A),
    ),
    ShopItemDef(
      id: 'bg_lavender',
      category: ShopItemCategory.background,
      coinPrice: 60,
      nameKey: 'shopBgLavender',
      descKey: 'shopBgLavenderDesc',
      icon: Icons.landscape_rounded,
      previewColor: Color(0xFFE8D4F0),
    ),
    ShopItemDef(
      id: 'bg_peach',
      category: ShopItemCategory.background,
      coinPrice: 60,
      nameKey: 'shopBgPeach',
      descKey: 'shopBgPeachDesc',
      icon: Icons.landscape_rounded,
      previewColor: Color(0xFFFFF0E8),
    ),
    ShopItemDef(
      id: 'remove_ads_coins',
      category: ShopItemCategory.feature,
      coinPrice: 250,
      nameKey: 'shopRemoveAds',
      descKey: 'shopRemoveAdsDesc',
      icon: Icons.block_rounded,
      previewColor: Color(0xFF6B8A84),
    ),
  ];

  static ShopItemDef? find(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }
}

/// Visual presets unlocked via shop.
class ShopVisuals {
  static LinearGradient? backgroundGradient(String? bgId) => switch (bgId) {
        'bg_lavender' => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8D4F0), Color(0xFFF0E8FF), Color(0xFFE8F8FF)],
          ),
        'bg_peach' => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF0E8), Color(0xFFFFE4D4), Color(0xFFFFF8F0)],
          ),
        _ => null,
      };

  static Color accentColor(String? themeId) => switch (themeId) {
        'theme_ocean' => const Color(0xFF7EC8E3),
        'theme_sunset' => const Color(0xFFFFB88C),
        'theme_forest' => const Color(0xFF5BB8A8),
        _ => const Color(0xFF5BB8A8),
      };

  static List<Color> ringColors(String? skinId, Color fallback) => switch (skinId) {
        'skin_gold' => [const Color(0xFFFFD700), const Color(0xFFFFB88C)],
        'skin_coral' => [const Color(0xFFFF6B8A), const Color(0xFFFFB88C)],
        _ => [fallback.withValues(alpha: 0.5), fallback, const Color(0xFFFFB88C)],
      };
}
