import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:airport_nav/core/theme/app_theme.dart';
import 'package:airport_nav/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('HomeScreen builds without exceptions at mobile width',
      (tester) async {
    // Tall viewport so all sections are laid out (ListView builds lazily).
    tester.view.physicalSize = const Size(375, 1700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);

    // The sections that were previously blank should now be present.
    expect(find.text('Live Departures'), findsOneWidget);
    expect(find.text('Your Upcoming Flight'), findsOneWidget);
    expect(find.text('Ask Assistant'), findsOneWidget);
  });
}
