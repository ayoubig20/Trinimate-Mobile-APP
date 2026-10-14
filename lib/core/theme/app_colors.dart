import 'package:flutter/material.dart';

/// LIGHT-FIRST design system (YourSportMatcher style, orange accent).
abstract final class AppColors {
  static const Color background = Color(0xFFFFFFFF);
  static const Color screenBackground = Color(0xFFF7F7F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF0F0F0);

  static const Color primary = Color(0xFFFF5A00);
  static const Color secondary = Color(0xFFD4EE2C);

  static const Color text = Color(0xFF171717);
  static const Color textMuted = Color(0xFF8A8A8A);

  /// Black at 8% opacity — hairlines on light backgrounds.
  static const Color divider = Color(0x14000000);

  /// Deterministic palette for PlayerAvatar backgrounds.
  static const List<Color> avatarPalette = [
    Color(0xFFFF5A00), // orange
    Color(0xFFD4EE2C), // lime
    Color(0xFF2C7AEE), // blue
    Color(0xFF9A4DEE), // purple
    Color(0xFF2CEEB8), // teal
    Color(0xFFEE2C6D), // pink
  ];
}