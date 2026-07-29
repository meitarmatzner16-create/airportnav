import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:airport_nav/core/branding/app_logo.dart';
import 'package:airport_nav/features/onboarding/presentation/splash_screen.dart';

Widget _app() => MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: '/splash',
        routes: [
          GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
          GoRoute(
              path: '/home',
              builder: (_, _) => const Scaffold(body: Text('HOME'))),
          GoRoute(
              path: '/onboarding',
              builder: (_, _) => const Scaffold(body: Text('ONBOARDING'))),
        ],
      ),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows the logo and leaves no pending timers', (t) async {
    await t.pumpWidget(_app());
    await t.pump();
    expect(find.byType(AppLogo), findsOneWidget);
    await t.pumpAndSettle();
    // Reaching here without "A Timer is still pending" is the assertion.
  });

  testWidgets('routes to onboarding when not yet seen', (t) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': false});
    await t.pumpWidget(_app());
    await t.pumpAndSettle();
    expect(find.text('ONBOARDING'), findsOneWidget);
  });

  testWidgets('routes straight home once onboarding has been seen', (t) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    await t.pumpWidget(_app());
    await t.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
  });
}
