import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:airport_nav/core/theme/app_theme.dart';
import 'package:airport_nav/core/widgets/app_shell.dart';

void main() {
  testWidgets('AppShell 5-tab nav (with hero) fits mobile width without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 780); // narrow phone
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            for (final p in ['/home', '/explore', '/voice-chat', '/flights', '/map'])
              GoRoute(
                path: p,
                builder: (_, _) => const Scaffold(body: SizedBox.shrink()),
              ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
    // All five tab labels render.
    for (final label in ['Home', 'Explore', 'Assistant', 'Flights', 'Map']) {
      expect(find.text(label), findsOneWidget);
    }
  });
}
