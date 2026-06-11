import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/iap_constants.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/buy_coins_sheet.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final shop = context.watch<ShopProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.t(context, 'shop')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${shop.coins} ⭐', style: TextStyle(fontWeight: FontWeight.w800, color: colors.primary)),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          if (!shop.starPurchaseEnabled)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: colors.cardBorder != null ? Border.all(color: colors.cardBorder!) : null,
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: colors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppStrings.t(context, 'iapOffline'),
                      style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          _EarnBanner(colors: colors),
          const SizedBox(height: 20),
          _CategorySection(
            title: AppStrings.t(context, 'shopThemes'),
            items: ShopCatalog.items.where((i) => i.category == ShopItemCategory.theme).toList(),
          ),
          const SizedBox(height: 16),
          _CategorySection(
            title: AppStrings.t(context, 'shopSkins'),
            items: ShopCatalog.items.where((i) => i.category == ShopItemCategory.skin).toList(),
          ),
          const SizedBox(height: 16),
          _CategorySection(
            title: AppStrings.t(context, 'shopBackgrounds'),
            items: ShopCatalog.items.where((i) => i.category == ShopItemCategory.background).toList(),
          ),
          const SizedBox(height: 16),
          _CategorySection(
            title: AppStrings.t(context, 'shopFeatures'),
            items: ShopCatalog.items.where((i) => i.category == ShopItemCategory.feature).toList(),
          ),
        ],
      ),
      floatingActionButton: shop.starPurchaseEnabled
          ? FloatingActionButton.extended(
              onPressed: () => BuyCoinsSheet.show(context),
              icon: const Icon(Icons.add),
              label: Text(AppStrings.t(context, 'buyStars')),
            )
          : null,
    );
  }
}

class _EarnBanner extends StatelessWidget {
  final AppPalette colors;

  const _EarnBanner({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary.withValues(alpha: 0.15), colors.primary.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: colors.cardBorder != null ? Border.all(color: colors.cardBorder!) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.t(context, 'earnStars'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 6),
          Text(AppStrings.t(context, 'earnStarsDesc'), style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant, height: 1.4)),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String title;
  final List<ShopItemDef> items;

  const _CategorySection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 10),
        ...items.map((item) => _ShopItemTile(item: item)),
      ],
    );
  }
}

class _ShopItemTile extends StatelessWidget {
  final ShopItemDef item;

  const _ShopItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final shop = context.watch<ShopProvider>();
    final owned = shop.owns(item.id);
    final equipped = shop.isEquipped(item.id, item.category);
    final canAfford = shop.coins >= item.coinPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: colors.cardDecoration(radius: 16),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: item.previewColor.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(item.icon, color: item.previewColor),
        ),
        title: Text(AppStrings.t(context, item.nameKey), style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(AppStrings.t(context, item.descKey), style: const TextStyle(fontSize: 12)),
        trailing: _trailing(context, shop, owned, equipped, canAfford),
      ),
    );
  }

  Widget _trailing(
    BuildContext context,
    ShopProvider shop,
    bool owned,
    bool equipped,
    bool canAfford,
  ) {
    if (owned) {
      if (item.category == ShopItemCategory.feature) {
        return Chip(label: Text(AppStrings.t(context, 'owned'), style: const TextStyle(fontSize: 11)));
      }
      return TextButton(
        onPressed: equipped
            ? () => shop.clearEquip(item.category)
            : () => shop.equip(item),
        child: Text(equipped ? AppStrings.t(context, 'equipped') : AppStrings.t(context, 'equip')),
      );
    }

    return FilledButton(
      onPressed: () async {
        if (canAfford) {
          final ok = await shop.buyWithCoins(item.id);
          if (context.mounted && !ok) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppStrings.t(context, 'notEnoughStars'))),
            );
          }
        } else if (shop.starPurchaseEnabled) {
          BuyCoinsSheet.show(context);
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.t(context, 'notEnoughStarsHint'))),
          );
        }
      },
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
      ),
      child: Text('${item.coinPrice} ⭐', style: const TextStyle(fontSize: 13)),
    );
  }
}
