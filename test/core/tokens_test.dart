// test/core/tokens_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_typography.dart';

void main() {
  test('Sky Pass core tokens have exact values', () {
    expect(AppColors.sky, const Color(0xFF3577E7));
    expect(AppColors.ink, const Color(0xFF0F2350));
    expect(AppColors.gold, const Color(0xFFC2A05A));
    expect(AppColors.paper, const Color(0xFFFCFCFC));
  });
  test('legacy names are re-pointed to Sky Pass', () {
    expect(AppColors.accent, AppColors.sky);       // interactive
    expect(AppColors.primary, AppColors.ink);      // brand/dark
    expect(AppColors.background, AppColors.paper);
  });
  testWidgets('every text role resolves to a single Nunito family', (tester) async {
    expect(AppTypography.textTheme.displayLarge!.fontFamily, contains('Nunito'));
    expect(AppTypography.textTheme.headlineMedium!.fontFamily, contains('Nunito'));
    expect(AppTypography.textTheme.bodyLarge!.fontFamily, contains('Nunito'));
    expect(AppTypography.textTheme.bodyMedium!.fontFamily, contains('Nunito'));
    expect(AppTypography.textTheme.labelSmall!.fontFamily, contains('Nunito'));
    expect(AppTypography.mono(fontSize: 14).fontFamily, contains('Nunito'));
  });
}
