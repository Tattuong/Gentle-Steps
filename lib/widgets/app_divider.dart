import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class AppDivider extends StatelessWidget {
  final double indent;
  final double endIndent;

  const AppDivider({
    super.key,
    this.indent = 16,
    this.endIndent = 16,
  });

  const AppDivider.menu({super.key}) : indent = 70, endIndent = 16;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.of(context).divider,
      indent: indent,
      endIndent: endIndent,
    );
  }
}
