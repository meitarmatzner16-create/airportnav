import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_spacing.dart';

/// Centralized elevation system. We avoid Material's default elevation in
/// favor of layered, soft shadows that give a calmer premium feel.
class AppShadows {
  AppShadows._();

  static const card = [
    BoxShadow(color: AppColors.shadowSoft, blurRadius: 1, offset: Offset(0, 1)),
    BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const cardHover = [
    BoxShadow(color: AppColors.shadow, blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: AppColors.shadowMedium, blurRadius: 24, offset: Offset(0, 8)),
  ];

  static const lifted = [
    BoxShadow(color: AppColors.shadowMedium, blurRadius: 28, offset: Offset(0, 14)),
  ];

  static const hero = [
    BoxShadow(color: AppColors.shadowSky, blurRadius: 30, offset: Offset(0, 14)),
  ];

  /// Sky-tinted accent glow (re-mapped from old accent to sky family).
  static const accentGlow = [
    BoxShadow(color: AppColors.shadowSky, blurRadius: 24, spreadRadius: 2, offset: Offset(0, 8)),
  ];
}

class AppTheme {
  AppTheme._();

  static const _systemOverlayLight = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.paper,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static const _systemOverlayDark = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.dBg,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.sky,
          onPrimary: Colors.white,
          primaryContainer: AppColors.skyTint,
          secondary: AppColors.sky,
          surface: AppColors.card,
          onSurface: AppColors.textColor,
          surfaceContainerHighest: AppColors.surfaceVariant,
          outline: AppColors.outline,
          outlineVariant: AppColors.hairline,
          error: AppColors.error,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.paper,
        textTheme: AppTypography.textTheme,
        splashFactory: InkSparkle.splashFactory,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          backgroundColor: AppColors.paper,
          foregroundColor: AppColors.ink,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: _systemOverlayLight,
          titleSpacing: AppSpacing.md,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            side: const BorderSide(color: AppColors.hairline, width: 1),
          ),
          color: AppColors.card,
          surfaceTintColor: Colors.transparent,
          margin: EdgeInsets.zero,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.hairline,
          thickness: 1,
          space: 1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.sky,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            textStyle: AppTypography.textTheme.titleMedium,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.sky,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            textStyle: AppTypography.textTheme.titleMedium,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.sky,
            textStyle: AppTypography.textTheme.labelLarge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.card,
          hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.muted,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            borderSide: const BorderSide(color: AppColors.hairline, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            borderSide: const BorderSide(color: AppColors.hairline, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            borderSide: const BorderSide(color: AppColors.sky, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.smMd,
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.skyTint,
          labelStyle: AppTypography.textTheme.labelLarge?.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          side: const BorderSide(color: Colors.transparent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          minVerticalPadding: AppSpacing.smMd,
          iconColor: AppColors.muted,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.ink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.dSky,
          onPrimary: Colors.white,
          primaryContainer: AppColors.dSurfaceVariant,
          secondary: AppColors.dSky,
          surface: AppColors.dSurface,
          onSurface: AppColors.dText,
          surfaceContainerHighest: AppColors.dSurfaceVariant,
          outline: AppColors.dSurfaceVariant,
          outlineVariant: AppColors.dHairline,
          error: AppColors.error,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.dBg,
        textTheme: AppTypography.textTheme.apply(
          bodyColor: AppColors.dText,
          displayColor: AppColors.dText,
        ),
        splashFactory: InkSparkle.splashFactory,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          backgroundColor: AppColors.dBg,
          foregroundColor: AppColors.dText,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: _systemOverlayDark,
          titleSpacing: AppSpacing.md,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            side: const BorderSide(color: AppColors.dHairline, width: 1),
          ),
          color: AppColors.dSurface,
          surfaceTintColor: Colors.transparent,
          margin: EdgeInsets.zero,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.dHairline,
          thickness: 1,
          space: 1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.dSky,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            textStyle: AppTypography.textTheme.titleMedium,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.dSky,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            textStyle: AppTypography.textTheme.titleMedium,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.dSky,
            textStyle: AppTypography.textTheme.labelLarge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.dSurface,
          hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.dMuted,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            borderSide: const BorderSide(color: AppColors.dHairline, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            borderSide: const BorderSide(color: AppColors.dHairline, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            borderSide: const BorderSide(color: AppColors.dSky, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.smMd,
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.dSurfaceVariant,
          labelStyle: AppTypography.textTheme.labelLarge?.copyWith(
            color: AppColors.dText,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          side: const BorderSide(color: Colors.transparent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          minVerticalPadding: AppSpacing.smMd,
          iconColor: AppColors.dMuted,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.dSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.dText,
          ),
        ),
      );
}
