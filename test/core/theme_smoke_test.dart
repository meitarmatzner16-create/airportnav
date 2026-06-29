// test/core/theme_smoke_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:airport_nav/core/theme/app_theme.dart';
import 'package:airport_nav/core/constants/app_colors.dart';

void main() {
  testWidgets('light & dark themes build and apply', (t) async {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      await t.pumpWidget(MaterialApp(theme: theme, home: const Scaffold(body: Text('x'))));
      expect(find.text('x'), findsOneWidget);
    }
    expect(AppTheme.light.colorScheme.primary, AppColors.sky);
  });
}
