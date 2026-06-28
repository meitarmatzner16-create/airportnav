import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary — deep navy (El Al-inspired)
  static const primary = Color(0xFF131137);
  static const primaryLight = Color(0xFF1B358F);
  static const primaryDark = Color(0xFF0C0D26);

  // Accent — turquoise for CTAs and interactive elements
  static const accent = Color(0xFF1FC5A5);
  static const accentLight = Color(0xFF4DDEC1);
  static const accentDark = Color(0xFF18A88C);

  // Secondary
  static const secondary = Color(0xFF1B358F);
  static const secondaryLight = Color(0xFF2E4EAF);

  // Neutrals
  static const background = Color(0xFFF4F5F7);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFECEEF2);
  static const onSurface = Color(0xFF1A1C2E);
  static const onSurfaceVariant = Color(0xFF5E6272);
  static const outline = Color(0xFFD0D3DC);

  // Dark theme
  static const darkBackground = Color(0xFF0A0B1A);
  static const darkSurface = Color(0xFF141530);
  static const darkSurfaceVariant = Color(0xFF252746);
  static const darkOnSurface = Color(0xFFECEDF5);
  static const darkOnSurfaceVariant = Color(0xFF8F92A8);

  // Semantic
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFEAB308);
  static const error = Color(0xFFDC2626);
  static const info = Color(0xFF1B358F);

  // Flight status
  static const statusOnTime = Color(0xFF16A34A);
  static const statusDelayed = Color(0xFFEAB308);
  static const statusCancelled = Color(0xFFDC2626);
  static const statusBoarding = Color(0xFF1FC5A5);
  static const statusLanded = Color(0xFF1B358F);

  // Pre-computed alpha variants (avoids withOpacity scroll distortion)
  static const primaryAlpha10 = Color(0x1A131137);
  static const primaryAlpha15 = Color(0x26131137);
  static const accentAlpha10 = Color(0x1A1FC5A5);
  static const accentAlpha15 = Color(0x261FC5A5);
  static const accentAlpha20 = Color(0x331FC5A5);
  static const whiteAlpha15 = Color(0x26FFFFFF);
  static const whiteAlpha20 = Color(0x33FFFFFF);
  static const whiteAlpha25 = Color(0x40FFFFFF);
  static const whiteAlpha80 = Color(0xCCFFFFFF);
  static const warningAlpha15 = Color(0x26EAB308);
  static const errorAlpha15 = Color(0x26DC2626);
  static const errorAlpha40 = Color(0x66DC2626);
  static const successAlpha15 = Color(0x2616A34A);

  // UI element colors
  static const star = Color(0xFFFBBF24);
  static const shadow = Color(0x0D000000);
  static const shadowMedium = Color(0x1A000000);
  static const shadowSoft = Color(0x08000000);
  static const shadowAccent = Color(0x141FC5A5);

  // Subtle hairline border used on cards/chips for definition without
  // a heavy 1-px line.
  static const hairline = Color(0xFFE6E8EE);
  static const hairlineDark = Color(0xFF2A2C46);

  // Offer category gradients (coordinated navy/teal family)
  static const gradientDiningStart = Color(0xFF1B358F);
  static const gradientDiningEnd = Color(0xFF1FC5A5);
  static const gradientShoppingStart = Color(0xFF131137);
  static const gradientShoppingEnd = Color(0xFF2E4EAF);
  static const gradientLoungeStart = Color(0xFF18A88C);
  static const gradientLoungeEnd = Color(0xFF4DDEC1);
  static const gradientTravelStart = Color(0xFF0C0D26);
  static const gradientTravelEnd = Color(0xFF1B358F);
  static const gradientDutyFreeStart = Color(0xFF1B358F);
  static const gradientDutyFreeEnd = Color(0xFF6C71C4);
}
