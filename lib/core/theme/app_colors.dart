import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color background = Color(0xFF000000);
  static const Color screenBackground = Color(0xFF0B0B0B);
  static const Color surface = Color(0xFF151515);
  static const Color surface2 = Color(0xFF222222);

  static const Color primary = Color(0xFFFF5A00);
  static const Color secondary = Color(0xFFD4EE2C);

  static const Color text = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9A9A9A);

  /// White at 8% opacity — used for dividers and hairlines.
  static const Color divider = Color(0x14FFFFFF);

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