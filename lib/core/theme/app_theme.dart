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

  static const accentGlow = [
    BoxShadow(color: AppColors.shadowAccent, blurRadius: 24, spreadRadius: 2, offset: Offset(0, 8)),
  ];
}

class AppTheme {
  AppTheme._();

  static const _systemOverlayLight = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static const _systemOverlayDark = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.darkBackground,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          primaryContainer: AppColors.primaryLight,
          secondary: AppColors.accent,
          secondaryContainer: AppColors.accentLight,
          surface: AppColors.surface,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.onSurface,
          onError: Colors.white,
          outline: AppColors.outline,
          outlineVariant: AppColors.hairline,
          surfaceContainerHighest: AppColors.surfaceVariant,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: AppTypography.textTheme,
        splashFactory: InkSparkle.splashFactory,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.onSurface,
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
          color: AppColors.surface,
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
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            textStyle: AppTypography.textTheme.titleMedium,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            textStyle: AppTypography.textTheme.titleMedium,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
            textStyle: AppTypography.textTheme.labelLarge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
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
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.smMd,
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceVariant,
          labelStyle: AppTypography.textTheme.labelLarge?.copyWith(
            color: AppColors.onSurface,
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
          iconColor: AppColors.onSurfaceVariant,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.primary,
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
          primary: AppColors.accentLight,
          primaryContainer: AppColors.primaryDark,
          secondary: AppColors.accent,
          secondaryContainer: AppColors.accentDark,
          surface: AppColors.darkSurface,
          error: AppColors.error,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: AppColors.darkOnSurface,
          onError: Colors.white,
          outline: AppColors.darkSurfaceVariant,
          outlineVariant: AppColors.hairlineDark,
          surfaceContainerHighest: AppColors.darkSurfaceVariant,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        textTheme: AppTypography.textTheme.apply(
          bodyColor: AppColors.darkOnSurface,
          displayColor: AppColors.darkOnSurface,
        ),
        splashFactory: InkSparkle.splashFactory,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          backgroundColor: AppColors.darkBackground,
          foregroundColor: AppColors.darkOnSurface,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: _systemOverlayDark,
          titleSpacing: AppSpacing.md,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            side: const BorderSide(color: AppColors.hairlineDark, width: 1),
          ),
          color: AppColors.darkSurface,
          surfaceTintColor: Colors.transparent,
          margin: EdgeInsets.zero,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.hairlineDark,
          thickness: 1,
          space: 1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            textStyle: AppTypography.textTheme.titleMedium,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            textStyle: AppTypography.textTheme.titleMedium,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accentLight,
            textStyle: AppTypography.textTheme.labelLarge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurface,
          hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.darkOnSurfaceVariant,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            borderSide: const BorderSide(color: AppColors.hairlineDark, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            borderSide: const BorderSide(color: AppColors.hairlineDark, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.smMd,
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.darkSurfaceVariant,
          labelStyle: AppTypography.textTheme.labelLarge?.copyWith(
            color: AppColors.darkOnSurface,
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
          iconColor: AppColors.darkOnSurfaceVariant,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.darkSurfaceVariant,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.darkOnSurface,
          ),
        ),
      );
}
