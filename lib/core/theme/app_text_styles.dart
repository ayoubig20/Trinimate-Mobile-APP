import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  /// Headlines — Barlow Condensed Black Italic, UPPERCASE, tight leading.
  static TextStyle headline({double size = 30, Color color = AppColors.text}) =>
      GoogleFonts.barlowCondensed(
        fontSize: size,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        color: color,
        letterSpacing: 1.2,
        height: 1.05,
      );

  /// Buttons & nav labels — Rajdhani Bold, UPPERCASE, wide tracking.
  static TextStyle button({Color color = Colors.white, double size = 15}) =>
      GoogleFonts.rajdhani(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 2.4,
      );

  /// Small labels — Rajdhani Bold.
  static TextStyle label({Color color = AppColors.textMuted, double size = 13}) =>
      GoogleFonts.rajdhani(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 1.5,
      );

  /// Body — Inter Regular.
  static TextStyle body({Color color = AppColors.text, double size = 14}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.45,
      );

  /// Body — Inter Medium.
  static TextStyle bodyMedium({Color color = AppColors.text, double size = 14}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.45,
      );
}