import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool withShadow;

  const AppLogo({
    super.key,
    required this.size,
    this.withShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      width: size,
      height: size,
      decoration: withShadow
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.35),
                  blurRadius: size * 0.25,
                  offset: Offset(0, size * 0.1),
                ),
              ],
            )
          : null,
      child: Image.asset(
        'assets/logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
