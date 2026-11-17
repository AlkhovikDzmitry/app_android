import 'package:flutter/material.dart';

class AppPalette {
  const AppPalette({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.accent,
    required this.background,
    required this.surface,
    required this.tabInactive,
    required this.splashStart,
    required this.splashMid,
    required this.textPrimary,
    required this.textSecondary,
    required this.error,
    required this.success,
    required this.divider,
    required this.cardBackground,
    required this.shadow,
    required this.gradientStart,
    required this.gradientEnd,
    required this.cardGradientStart,
    required this.cardGradientEnd,
    required this.outlineStrong,
    required this.primaryButton,
  });

  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color accent;
  final Color background;
  final Color surface;
  final Color tabInactive;
  final Color splashStart;
  final Color splashMid;
  final Color textPrimary;
  final Color textSecondary;
  final Color error;
  final Color success;
  final Color divider;
  final Color cardBackground;
  final Color shadow;
  final Color gradientStart;
  final Color gradientEnd;
  final Color cardGradientStart;
  final Color cardGradientEnd;

  /// Акцентная обводка карточек поверх фона: тёмно-синий в светлой теме,
  /// облегчённый индиго в тёмной (там `#001A5A` дал бы ~1.4:1 и рамку не видно).
  final Color outlineStrong;

  /// Фон залитых кнопок под белым текстом. В светлой теме совпадает с
  /// [primary]; в тёмной — приглушённый индиго: `primary` даёт на белом
  /// тексте лишь 4.0:1, здесь 6.2:1 при тех же 3.5:1 у самого `primary`
  /// в роли цвета иконок и текста.
  final Color primaryButton;
}

class AppColors {
  AppColors._();

  static bool isDark = false;

  static const AppPalette light = AppPalette(
    primary: Color(0xFF3D3C7A),
    primaryDark: Color(0xFF2E2D5C),
    primaryLight: Color(0xFFE9E9F3),
    accent: Color(0xFF34C8E8),
    background: Color(0xFFF4F3EF),
    surface: Color(0xFFFFFEFC),
    tabInactive: Color(0xFFE4E2DC),
    splashStart: Color(0xFF3D3C7A),
    splashMid: Color(0xFF001A5A),
    textPrimary: Color(0xFF1B1C22),
    textSecondary: Color(0xFF6F706F),
    error: Color(0xFFEF4444),
    success: Color(0xFF10B981),
    divider: Color(0xFFE5E2DB),
    cardBackground: Color(0xFFFFFEFC),
    shadow: Color(0x14141A2E),
    gradientStart: Color(0xFF3D3C7A),
    gradientEnd: Color(0xFF001A5A),
    cardGradientStart: Color(0xFFFFFEFC),
    cardGradientEnd: Color(0xFFF4F3EF),
    outlineStrong: Color(0xFF001A5A),
    primaryButton: Color(0xFF3D3C7A),
  );

  static const AppPalette dark = AppPalette(
    primary: Color(0xFF6C7AC8),
    primaryDark: Color(0xFF3D3C7A),
    primaryLight: Color(0xFF2F3663),
    accent: Color(0xFF34C8E8),
    background: Color(0xFF1B1F2A),
    surface: Color(0xFF242C3B),
    tabInactive: Color(0xFF353F54),
    splashStart: Color(0xFF3D3C7A),
    splashMid: Color(0xFF6C7AC8),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9AA3B2),
    error: Color(0xFFF87171),
    success: Color(0xFF34D399),
    divider: Color(0xFF353F54),
    cardBackground: Color(0xFF242C3B),
    shadow: Color(0x66000000),
    gradientStart: Color(0xFF3D3C7A),
    gradientEnd: Color(0xFF001A5A),
    cardGradientStart: Color(0xFF353F54),
    cardGradientEnd: Color(0xFF1B1F2A),
    outlineStrong: Color(0xFF6C7AC8),
    primaryButton: Color(0xFF5A5A9E),
  );

  static AppPalette get _p => isDark ? dark : light;

  static Color get primary => _p.primary;
  static Color get primaryDark => _p.primaryDark;
  static Color get primaryLight => _p.primaryLight;
  static Color get accent => _p.accent;
  static Color get background => _p.background;
  static Color get surface => _p.surface;
  static Color get tabInactive => _p.tabInactive;
  static Color get splashStart => _p.splashStart;
  static Color get splashMid => _p.splashMid;
  static Color get textPrimary => _p.textPrimary;
  static Color get textSecondary => _p.textSecondary;
  static Color get error => _p.error;
  static Color get success => _p.success;
  static Color get divider => _p.divider;
  static Color get cardBackground => _p.cardBackground;
  static Color get shadow => _p.shadow;
  static Color get gradientStart => _p.gradientStart;
  static Color get gradientEnd => _p.gradientEnd;
  static Color get cardGradientStart => _p.cardGradientStart;
  static Color get cardGradientEnd => _p.cardGradientEnd;
  static Color get outlineStrong => _p.outlineStrong;
  static Color get primaryButton => _p.primaryButton;

  static List<Color> get gradient => [gradientStart, gradientEnd];
  static List<Color> get cardGradient => [cardGradientStart, cardGradientEnd];
}
