import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF5BB8A8);
  static const Color primaryLight = Color(0xFF8ED4C8);
  static const Color primaryDark = Color(0xFF3D9A8A);
  static const Color secondary = Color(0xFFFFB88C);
  static const Color accent = Color(0xFF7EC8E3);

  static const Color background = Color(0xFFF8FFFE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE8F5F2);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1E3A35);
  static const Color onSurfaceVariant = Color(0xFF6B8A84);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4F0EC), Color(0xFFFFF0E8), Color(0xFFE8F8FF)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5BB8A8), Color(0xFF7EC8E3)],
  );

  static const LinearGradient progressGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5BB8A8), Color(0xFFFFB88C)],
  );

  static Color progressColor(double ratio) {
    if (ratio >= 1.0) return success;
    if (ratio >= 0.75) return primary;
    if (ratio >= 0.5) return accent;
    if (ratio >= 0.25) return secondary;
    return primaryLight;
  }
}
