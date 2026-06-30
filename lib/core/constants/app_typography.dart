import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sky Pass type: Manrope (display/UI — calm, even), Inter (long-form body), Space Mono (data).
class AppTypography {
  AppTypography._();

  static TextStyle mono({double fontSize = 14, FontWeight weight = FontWeight.w700, Color? color}) =>
      GoogleFonts.spaceMono(fontSize: fontSize, fontWeight: weight, color: color, letterSpacing: 0);

  static TextStyle _d(double s, {double sp = -0.4, FontWeight w = FontWeight.w700, double h = 1.15}) =>
      GoogleFonts.manrope(fontSize: s, fontWeight: w, letterSpacing: sp, height: h);
  static TextStyle _ui(double s, {double sp = 0, FontWeight w = FontWeight.w600}) =>
      GoogleFonts.manrope(fontSize: s, fontWeight: w, letterSpacing: sp);
  static TextStyle _body(double s, {double sp = 0, FontWeight w = FontWeight.w400, double h = 1.5}) =>
      GoogleFonts.inter(fontSize: s, fontWeight: w, letterSpacing: sp, height: h);

  static TextTheme get textTheme => TextTheme(
        displayLarge: _d(36, sp: -0.3, w: FontWeight.w700, h: 1.1),
        displayMedium: _d(30, sp: -0.3),
        displaySmall: _d(24, sp: -0.4),
        headlineLarge: _d(22, sp: -0.3, h: 1.25),
        headlineMedium: _ui(18, sp: -0.2, w: FontWeight.w700),
        headlineSmall: _ui(17, sp: -0.2, w: FontWeight.w700),
        titleLarge: _ui(16, sp: -0.1, w: FontWeight.w700),
        titleMedium: _ui(14, w: FontWeight.w600),
        titleSmall: _ui(12, sp: 0.2, w: FontWeight.w600),
        bodyLarge: _body(16),
        bodyMedium: _body(14),
        bodySmall: _body(13, sp: 0.1),
        labelLarge: _ui(14, sp: 0.1, w: FontWeight.w600),
        labelMedium: _ui(12, sp: 0.2, w: FontWeight.w600),
        labelSmall: _ui(11, sp: 0.3, w: FontWeight.w600),
      );
}
