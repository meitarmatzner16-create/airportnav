import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:airport_nav/core/branding/app_logo.dart';

void main() {
  testWidgets('renders at every size without exception', (t) async {
    for (final s in [20.0, 28.0, 56.0, 104.0, 1024.0]) {
      await t.pumpWidget(MaterialApp(
        home: Scaffold(body: Center(child: AppLogo(size: s))),
      ));
      await t.pump();
      expect(t.takeException(), isNull, reason: 'size $s threw');
    }
  });

  testWidgets('renders every variant without exception', (t) async {
    for (final v in AppLogoVariant.values) {
      await t.pumpWidget(MaterialApp(
        home: Scaffold(body: Center(child: AppLogo(size: 64, variant: v))),
      ));
      await t.pump();
      expect(t.takeException(), isNull, reason: '$v threw');
    }
  });

  testWidgets('renders mid-animation progress values without exception',
      (t) async {
    await t.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: AppLogo(
            size: 116,
            tileProgress: 0.4,
            routeProgress: 0.5,
            planeProgress: 0.2,
          ),
        ),
      ),
    ));
    await t.pump();
    expect(t.takeException(), isNull);
  });

  test('route is hidden below 24px and shown at or above it', () {
    expect(const AppLogo(size: 20).routeVisible, isFalse);
    expect(const AppLogo(size: 23.9).routeVisible, isFalse);
    expect(const AppLogo(size: 24).routeVisible, isTrue);
    expect(const AppLogo(size: 28).routeVisible, isTrue);
  });

  test('explicit showRoute always wins over the size rule', () {
    expect(const AppLogo(size: 20, showRoute: true).routeVisible, isTrue);
    expect(const AppLogo(size: 64, showRoute: false).routeVisible, isFalse);
  });

  testWidgets('lockup renders the wordmark', (t) async {
    await t.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: AppLogoLockup(size: 30))),
    ));
    await t.pump();
    expect(find.text('AirportNav'), findsOneWidget);
    expect(find.byType(AppLogo), findsOneWidget);
  });
}
