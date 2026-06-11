import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/iap_constants.dart';
import '../../providers/shop_provider.dart';
import '../../providers/step_provider.dart';
import '../../screens/shop/shop_screen.dart';
import '../../widgets/buy_coins_sheet.dart';
import '../../widgets/step_progress_ring.dart';

class StepHomeScreen extends StatefulWidget {
  const StepHomeScreen({super.key});

  @override
  State<StepHomeScreen> createState() => _StepHomeScreenState();
}

class _StepHomeScreenState extends State<StepHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncRewards());
  }

  void _syncRewards() {
    if (!mounted) return;
    final steps = context.read<StepProvider>();
    final shop = context.read<ShopProvider>();
    shop.syncDailyRewards(
      todaySteps: steps.todaySteps,
      goal: steps.goal,
      goalReached: steps.goalReached,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final provider = context.watch<StepProvider>();
    final shop = context.watch<ShopProvider>();
    final locale = Localizations.localeOf(context).languageCode;
    final dateStr = DateFormat('EEEE, dd/MM/yyyy', locale).format(DateTime.now());
    final pct = (provider.progress * 100).round();
    final bgGradient = shop.homeGradient ?? colors.softGradient;
    final accent = shop.activeTheme != null ? shop.accentOverride : colors.primary;
    final ringColors = ShopVisuals.ringColors(shop.activeSkin, accent);

    WidgetsBinding.instance.addPostFrameCallback((_) => _syncRewards());

    return Container(
      decoration: BoxDecoration(gradient: bgGradient),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.t(context, 'today'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(dateStr, style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
                    ],
                  ),
                ),
                _StarsChip(shop: shop),
              ],
            ),
            const SizedBox(height: 28),
            if (!provider.permissionGranted)
              _PermissionBanner(onTap: () => provider.requestPermission(), accent: accent)
            else
              Center(
                child: Column(
                  children: [
                    StepProgressRing(
                      steps: provider.todaySteps,
                      goal: provider.goal,
                      ringColors: ringColors,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.t(context, 'stepsToday'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      AppStrings.t(context, 'progress', params: {'pct': '$pct'}),
                      style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: colors.cardBorder != null ? Border.all(color: colors.cardBorder!.withValues(alpha: 0.5)) : null,
              ),
              child: Row(
                children: [
                  Text(provider.goalReached ? '🎉' : '👟', style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppStrings.t(context, provider.motivationKey()),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    icon: Icons.straighten_rounded,
                    label: AppStrings.t(context, 'distance'),
                    value: provider.distanceKm.toStringAsFixed(2),
                    unit: AppStrings.t(context, 'km'),
                    accent: accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    icon: Icons.local_fire_department_rounded,
                    label: AppStrings.t(context, 'calories'),
                    value: provider.calories.round().toString(),
                    unit: AppStrings.t(context, 'kcal'),
                    accent: accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _MetricTile(
              icon: Icons.flag_rounded,
              label: AppStrings.t(context, 'dailyGoal'),
              value: NumberFormat.decimalPattern().format(provider.goal),
              unit: AppStrings.t(context, 'steps'),
              wide: true,
              accent: accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _StarsChip extends StatelessWidget {
  final ShopProvider shop;

  const _StarsChip({required this.shop});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Material(
      color: colors.surface.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen())),
        onLongPress: shop.starPurchaseEnabled ? () => BuyCoinsSheet.show(context) : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⭐', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text('${shop.coins}', style: TextStyle(fontWeight: FontWeight.w800, color: colors.primary)),
              if (shop.starPurchaseEnabled) ...[
                const SizedBox(width: 4),
                Icon(Icons.add_circle_outline, size: 18, color: colors.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionBanner extends StatelessWidget {
  final VoidCallback onTap;
  final Color accent;

  const _PermissionBanner({required this.onTap, required this.accent});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: colors.cardDecoration(),
      child: Column(
        children: [
          const Text('📱', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            AppStrings.t(context, 'sensorOff'),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.t(context, 'sensorOffSub'),
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(backgroundColor: accent),
            child: Text(AppStrings.t(context, 'grantPermission')),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final bool wide;
  final Color accent;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.accent,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: colors.cardDecoration(radius: 18),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 4),
                    Text(unit, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
