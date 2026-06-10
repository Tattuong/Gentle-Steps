import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class StepStatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String? suffix;
  final bool wide;

  const StepStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.suffix,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 4),
                Text(suffix!, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
