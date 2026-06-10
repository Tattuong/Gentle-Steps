import 'package:flutter/material.dart';

@immutable
class AppPalette {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color primary;
  final Color divider;
  final LinearGradient softGradient;
  final double cardShadowOpacity;
  final Color? cardBorder;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.primary,
    required this.divider,
    required this.softGradient,
    required this.cardShadowOpacity,
    this.cardBorder,
  });

  static const light = AppPalette(
    background: Color(0xFFF8FFFE),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFE8F5F2),
    onSurface: Color(0xFF1E3A35),
    onSurfaceVariant: Color(0xFF6B8A84),
    primary: Color(0xFF5BB8A8),
    divider: Color(0xFFF0F2F5),
    softGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFD4F0EC), Color(0xFFFFF0E8), Color(0xFFE8F8FF)],
    ),
    cardShadowOpacity: 0.04,
  );

  static const dark = AppPalette(
    background: Color(0xFF0D1917),
    surface: Color(0xFF162521),
    surfaceVariant: Color(0xFF1E302C),
    onSurface: Color(0xFFE8F5F2),
    onSurfaceVariant: Color(0xFF8FA9A3),
    primary: Color(0xFF6ECABB),
    divider: Color(0xFF243D38),
    softGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0D1917), Color(0xFF122420), Color(0xFF101E24)],
    ),
    cardShadowOpacity: 0.35,
    cardBorder: Color(0xFF2A423D),
  );

  BoxDecoration cardDecoration({double radius = 20}) => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radius),
        border: cardBorder != null ? Border.all(color: cardBorder!) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: cardShadowOpacity),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );
}

class AppColors {
  static AppPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? AppPalette.dark : AppPalette.light;

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
    if (ratio >= 0.75) return primaryLight;
    if (ratio >= 0.5) return accent;
    if (ratio >= 0.25) return secondary;
    return primary;
  }
}
