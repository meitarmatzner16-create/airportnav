// test/core/contrast_test.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:airport_nav/core/constants/app_colors.dart';

double _lin(double c) => c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
double _lum(Color c) =>
    0.2126 * _lin((c.r * 255.0).round().clamp(0, 255) / 255) +
    0.7152 * _lin((c.g * 255.0).round().clamp(0, 255) / 255) +
    0.0722 * _lin((c.b * 255.0).round().clamp(0, 255) / 255);
double ratio(Color a, Color b) {
  final l1 = _lum(a), l2 = _lum(b);
  return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
}

void main() {
  test('normal text pairs meet AA (>=4.5:1)', () {
    expect(ratio(AppColors.textColor, AppColors.paper), greaterThanOrEqualTo(4.5));
    expect(ratio(AppColors.muted, AppColors.paper), greaterThanOrEqualTo(4.5));
    expect(ratio(Colors.white, AppColors.skyPressed), greaterThanOrEqualTo(4.5));
    expect(ratio(AppColors.goldText, AppColors.paper), greaterThanOrEqualTo(4.5));
    expect(ratio(AppColors.dText, AppColors.dBg), greaterThanOrEqualTo(4.5));
  });
  test('large/bold pairs meet AA-large (>=3:1)', () {
    expect(ratio(Colors.white, AppColors.sky), greaterThanOrEqualTo(3.0)); // route letters, buttons
  });
}
