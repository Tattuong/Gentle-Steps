import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/iap_constants.dart';
import '../core/services/iap_service.dart';
import '../providers/shop_provider.dart';

class BuyCoinsSheet extends StatelessWidget {
  const BuyCoinsSheet({super.key});

  static Future<void> show(BuildContext context) {
    final shop = context.read<ShopProvider>();
    if (!shop.starPurchaseEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.t(context, 'iapOffline'))),
      );
      return Future.value();
    }
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BuyCoinsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final shop = context.watch<ShopProvider>();
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: colors.cardBorder != null ? Border(top: BorderSide(color: colors.cardBorder!)) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.t(context, 'buyStars'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                          Text(
                            AppStrings.t(context, 'buyStarsDesc'),
                            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${shop.coins} ⭐', style: TextStyle(fontWeight: FontWeight.w800, color: colors.primary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.paddingOf(context).bottom + 12),
              shrinkWrap: true,
              children: [
                ...List.generate(IapProducts.consumables.length, (i) {
                  final id = IapProducts.consumables[i];
                  final product = IapService.instance.products[id];
                  final coins = IapProducts.coinAmounts[id] ?? 0;
                  final packNum = i + 1;
                  return _CoinPackTile(
                    title: AppStrings.t(context, 'starPack', params: {'n': '$packNum'}),
                    coins: coins,
                    price: product?.price ?? '—',
                    loading: shop.purchasing,
                    bestValue: packNum == 10,
                    onTap: shop.purchasing ? null : () => shop.purchaseProduct(id),
                  );
                }),
                const SizedBox(height: 8),
                _CoinPackTile(
                  title: AppStrings.t(context, 'removeAds'),
                  subtitle: AppStrings.t(context, 'removeAdsIapDesc'),
                  icon: Icons.block_rounded,
                  price: IapService.instance.products[IapProducts.removeAds]?.price ?? '—',
                  loading: shop.purchasing,
                  highlight: true,
                  onTap: shop.purchasing || shop.removeAds
                      ? null
                      : () => shop.purchaseProduct(IapProducts.removeAds),
                ),
                Center(
                  child: TextButton(
                    onPressed: shop.purchasing ? null : () => shop.restorePurchases(),
                    child: Text(AppStrings.t(context, 'restorePurchases')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinPackTile extends StatelessWidget {
  final int? coins;
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final String price;
  final bool loading;
  final bool highlight;
  final bool bestValue;
  final VoidCallback? onTap;

  const _CoinPackTile({
    this.coins,
    this.title,
    this.subtitle,
    this.icon,
    required this.price,
    this.loading = false,
    this.highlight = false,
    this.bestValue = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: highlight ? colors.primary.withValues(alpha: 0.08) : colors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon ?? Icons.star_rounded, color: colors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title ?? '$coins ⭐',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      if (subtitle != null)
                        Text(subtitle!, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant))
                      else if (coins != null)
                        Text(
                          '$coins ⭐${bestValue ? ' · ${AppStrings.t(context, 'bestValue')}' : ''}',
                          style: TextStyle(fontSize: 12, color: bestValue ? colors.primary : colors.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                if (loading)
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(price, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
