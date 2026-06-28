import 'package:flutter/material.dart';

/// Sky Pass palette. New semantic names are canonical; legacy names are kept
/// as aliases (re-pointed) so existing token-driven screens adopt the new look.
class AppColors {
  AppColors._();

  // ---- Sky Pass · light ----
  static const sky = Color(0xFF3577E7);
  static const sky2 = Color(0xFF5895F3);
  static const skyPressed = Color(0xFF2A60C4); // small white text on blue
  static const skyTint = Color(0xFFEAF1FE);
  static const ink = Color(0xFF0F2350);
  static const textColor = Color(0xFF14213D);
  static const muted = Color(0xFF6B7488);
  static const gold = Color(0xFFC2A05A);
  static const goldSoft = Color(0xFFE8D6AE);
  static const goldText = Color(0xFF8A6D2F); // gold that must carry small text (AA)
  static const paper = Color(0xFFF7F5EF);
  static const card = Color(0xFFFFFFFF);
  static const hairline = Color(0xFFECE6D8);
  static const hairlineCool = Color(0xFFE2E8F4);

  // ---- Semantic ----
  static const success = Color(0xFF1FA971);
  static const warning = Color(0xFFE8A93B);
  static const error = Color(0xFFE5484D);
  static const info = sky;

  // Flight status
  static const statusOnTime = success;
  static const statusDelayed = warning;
  static const statusCancelled = error;
  static const statusBoarding = sky;
  static const statusScheduled = muted;
  static const statusLanded = ink;

  // ---- Sky Pass · dark ----
  static const dBg = Color(0xFF0B1020);
  static const dSurface = Color(0xFF131A30);
  static const dSurfaceVariant = Color(0xFF1E2942);
  static const dSky = Color(0xFF5C92F2);
  static const dGold = Color(0xFFCBA968);
  static const dText = Color(0xFFEAEEF8);
  static const dMuted = Color(0xFF93A0BC);
  static const dHairline = Color(0xFF243150);

  // ---- Legacy aliases (re-pointed) ----
  static const primary = ink;
  static const primaryLight = sky;
  static const primaryDark = Color(0xFF081A3D);
  static const accent = sky;
  static const accentLight = sky2;
  static const accentDark = skyPressed;
  static const secondary = sky;
  static const background = paper;
  static const surface = card;
  static const surfaceVariant = Color(0xFFEFE9DB);
  static const onSurface = textColor;
  static const onSurfaceVariant = muted;
  static const outline = Color(0xFFD8D2C4);
  static const star = gold;

  static const darkBackground = dBg;
  static const darkSurface = dSurface;
  static const darkSurfaceVariant = dSurfaceVariant;
  static const darkOnSurface = dText;
  static const darkOnSurfaceVariant = dMuted;
  static const hairlineDark = dHairline;

  // Pre-computed alpha variants (avoid withOpacity scroll distortion)
  static const skyAlpha10 = Color(0x1A3577E7);
  static const skyAlpha15 = Color(0x263577E7);
  static const skyAlpha20 = Color(0x333577E7);
  static const goldAlpha15 = Color(0x26C2A05A);
  static const inkAlpha10 = Color(0x1A0F2350);
  static const whiteAlpha15 = Color(0x26FFFFFF);
  static const whiteAlpha20 = Color(0x33FFFFFF);
  static const whiteAlpha25 = Color(0x40FFFFFF);
  static const whiteAlpha80 = Color(0xCCFFFFFF);
  static const successAlpha15 = Color(0x261FA971);
  static const warningAlpha15 = Color(0x26E8A93B);
  static const errorAlpha15 = Color(0x26E5484D);

  // Shadows
  static const shadowSoft = Color(0x08000000);
  static const shadow = Color(0x0D000000);
  static const shadowMedium = Color(0x1A000000);
  static const shadowSky = Color(0x593577E7); // sky-tinted hero shadow

  // Offer category gradients (re-mapped to sky/gold family)
  static const gradientDiningStart = sky;
  static const gradientDiningEnd = sky2;
  static const gradientShoppingStart = ink;
  static const gradientShoppingEnd = sky;
  static const gradientLoungeStart = Color(0xFF1B6F6A);
  static const gradientLoungeEnd = Color(0xFF36C5A0);
  static const gradientTravelStart = Color(0xFF081A3D);
  static const gradientTravelEnd = sky;
  static const gradientDutyFreeStart = sky;
  static const gradientDutyFreeEnd = Color(0xFF8AB4FA);
}
