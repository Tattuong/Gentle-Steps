import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class StepStatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String? suffix;

  const StepStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: colors.cardDecoration(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              if (suffix != null) ...[
                const SizedBox(width: 4),
                Text(suffix!, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
