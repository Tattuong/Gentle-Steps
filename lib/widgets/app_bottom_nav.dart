import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final items = [
      _NavItem(Icons.directions_walk_outlined, Icons.directions_walk, 'home'),
      _NavItem(Icons.bar_chart_outlined, Icons.bar_chart, 'stats'),
      _NavItem(Icons.calendar_month_outlined, Icons.calendar_month, 'history'),
      _NavItem(Icons.settings_outlined, Icons.settings, 'settings'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: colors.cardBorder != null ? Border(top: BorderSide(color: colors.cardBorder!)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: colors.cardShadowOpacity),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final active = currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          active ? item.activeIcon : item.icon,
                          color: active ? colors.primary : colors.onSurfaceVariant,
                          size: 24,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppStrings.t(context, item.labelKey),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                            color: active ? colors.primary : colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String labelKey;

  _NavItem(this.icon, this.activeIcon, this.labelKey);
}
