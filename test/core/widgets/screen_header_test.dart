import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:airport_nav/core/theme/app_theme.dart';
import 'package:airport_nav/core/widgets/screen_header.dart';

/// Every screen title has to start at the same y, whether or not the screen
/// has header actions. Explore and Flights hand-roll their headers with a
/// 12px top pad and the chip beside the title; ScreenHeader used to stack
/// actions in a row *above* the title, which pushed Assistant ~44px lower.
Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );

/// Distance from the top of the header block to the top of the title text.
Future<double> _titleOffset(
  WidgetTester tester, {
  List<Widget> actions = const [],
  String? subtitle,
}) async {
  await tester.pumpWidget(_wrap(
    ScreenHeader(
      title: 'Assistant',
      subtitle: subtitle,
      actions: actions,
    ),
  ));
  final headerTop = tester.getTopLeft(find.byType(ScreenHeader)).dy;
  final titleTop = tester.getTopLeft(find.text('Assistant')).dy;
  return titleTop - headerTop;
}

void main() {
  group('ScreenHeader title placement', () {
    testWidgets('title starts 12px down, matching Explore and Flights',
        (t) async {
      expect(await _titleOffset(t), 12);
    });

    testWidgets('actions do not push the title down', (t) async {
      final withoutActions = await _titleOffset(t);
      final withActions = await _titleOffset(
        t,
        actions: const [TonalPill(label: 'JFK', icon: Icons.public_rounded)],
      );
      expect(withActions, withoutActions);
    });

    testWidgets('a subtitle does not push the title down', (t) async {
      final bare = await _titleOffset(t);
      final withSubtitle =
          await _titleOffset(t, subtitle: 'AI-powered airport planner');
      expect(withSubtitle, bare);
    });

    testWidgets('actions sit beside the title, not above it', (t) async {
      await t.pumpWidget(_wrap(
        const ScreenHeader(
          title: 'Assistant',
          subtitle: 'AI-powered airport planner',
          actions: [TonalPill(label: 'JFK', icon: Icons.public_rounded)],
        ),
      ));
      final title = t.getRect(find.text('Assistant'));
      final pill = t.getRect(find.text('JFK'));
      // Overlapping vertical bands means they share a row.
      expect(pill.top, lessThan(title.bottom));
      expect(pill.left, greaterThan(title.right));
      expect(t.takeException(), isNull);
    });

    // Actions now share the title's row, so the title/subtitle column is
    // width-constrained. Narrow phones must degrade by ellipsising, never by
    // overflowing. (Real text width cannot be asserted here: flutter_test
    // substitutes a font whose every glyph is a full em square, so measured
    // widths are ~2x what Nunito actually renders.)
    for (final width in [390.0, 360.0, 320.0]) {
      testWidgets('lays out without overflow at ${width}px', (t) async {
        t.view.devicePixelRatio = 1.0;
        t.view.physicalSize = Size(width, 844);
        addTearDown(t.view.reset);

        await t.pumpWidget(_wrap(
          const ScreenHeader(
            title: 'Assistant',
            subtitle: 'AI-powered airport planner',
            actions: [
              TonalPill(label: 'JFK', icon: Icons.public_rounded),
              SizedBox(width: 44, height: 44),
            ],
          ),
        ));

        expect(t.takeException(), isNull);
        // Title placement holds regardless of how tight the width gets.
        final headerTop = t.getTopLeft(find.byType(ScreenHeader)).dy;
        expect(t.getTopLeft(find.text('Assistant')).dy - headerTop, 12);
      });
    }

    testWidgets('renders with a greeting without overflowing', (t) async {
      await t.pumpWidget(_wrap(
        const ScreenHeader(
          greeting: 'Good afternoon',
          title: 'Assistant',
          subtitle: 'AI-powered airport planner',
          actions: [TonalPill(label: 'JFK', icon: Icons.public_rounded)],
        ),
      ));
      expect(find.text('Good afternoon'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });
}
