import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:airport_nav/core/theme/app_theme.dart';
import 'package:airport_nav/features/arrived/presentation/screens/arrived_options_screen.dart';
import 'package:airport_nav/features/arrived/presentation/screens/arrived_screen.dart';

void main() {
  testWidgets('welcome page offers categories, nearby tiles and the lounge',
      (t) async {
    t.view.physicalSize = const Size(375, 1400);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);

    await t.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const ArrivedScreen()),
    );
    await t.pump(const Duration(milliseconds: 50));

    expect(find.text("Welcome! You've arrived"), findsOneWidget);
    expect(find.text('Toilets'), findsWidgets);
    expect(find.text('Transport'), findsOneWidget);
    expect(find.text('Popular near you'), findsOneWidget);
    expect(find.text('Baggage claim'), findsOneWidget);
    expect(find.text('Airport Lounge'), findsOneWidget);
    expect(find.text('Live airport updates'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('options page lists the ways out and the services', (t) async {
    t.view.physicalSize = const Size(375, 1400);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);

    await t.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const ArrivedOptionsScreen()),
    );
    await t.pump(const Duration(milliseconds: 50));

    expect(find.text("You've arrived"), findsOneWidget);
    expect(find.text('To airport exit'), findsOneWidget);
    expect(find.text('To baggage claim'), findsOneWidget);
    expect(find.text('To transport'), findsOneWidget);
    expect(find.text('Food & Drink'), findsOneWidget);
    expect(find.text('Baggage Services'), findsOneWidget);
    expect(find.text('Explore the airport'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
