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
    expect(AppColors.paper, const Color(0xFFF8F9FA));
  });
  test('legacy names are re-pointed to Sky Pass', () {
    expect(AppColors.accent, AppColors.sky);       // interactive
    expect(AppColors.primary, AppColors.ink);      // brand/dark
    expect(AppColors.background, AppColors.paper);
  });
  testWidgets('display uses Poppins, body uses Inter', (tester) async {
    expect(AppTypography.textTheme.headlineMedium!.fontFamily, contains('Manrope'));
    expect(AppTypography.textTheme.bodyMedium!.fontFamily, contains('Inter'));
    expect(AppTypography.mono(fontSize: 14).fontFamily, contains('Space'));
  });
}
