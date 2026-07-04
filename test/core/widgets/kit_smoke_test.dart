import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:airport_nav/core/theme/app_theme.dart';
import 'package:airport_nav/core/widgets/app_card.dart';
import 'package:airport_nav/core/widgets/status_badge.dart';
import 'package:airport_nav/core/widgets/state_views.dart';
import 'package:airport_nav/core/widgets/gradient_hero.dart';
import 'package:airport_nav/core/widgets/info_row.dart';
import 'package:airport_nav/core/widgets/gold_divider.dart';
import 'package:airport_nav/core/widgets/app_buttons.dart';
import 'package:airport_nav/core/widgets/rating_stars.dart';
import 'package:airport_nav/core/widgets/category_filter_chips.dart';
import 'package:airport_nav/core/widgets/search_bar_widget.dart';

Widget _wrap(Widget child, {bool dark = false}) => MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: child),
    );

void main() {
  // ── AppCard ────────────────────────────────────────────────────────────────
  group('AppCard', () {
    testWidgets('renders child in light mode', (t) async {
      await t.pumpWidget(_wrap(const AppCard(child: Text('Hello'))));
      expect(find.text('Hello'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('renders child in dark mode', (t) async {
      await t.pumpWidget(_wrap(const AppCard(child: Text('Dark')), dark: true));
      expect(find.text('Dark'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('selected border does not throw', (t) async {
      await t
          .pumpWidget(_wrap(const AppCard(selected: true, child: Text('Sel'))));
      expect(find.text('Sel'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('tappable variant does not throw', (t) async {
      await t
          .pumpWidget(_wrap(AppCard(onTap: () {}, child: const Text('Tap'))));
      await t.tap(find.text('Tap'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });
  });

  // ── StatusBadge ───────────────────────────────────────────────────────────
  group('StatusBadge', () {
    for (final s in [
      'on_time',
      'boarding',
      'delayed',
      'cancelled',
      'scheduled',
      'landed'
    ]) {
      testWidgets('renders status=$s', (t) async {
        await t
            .pumpWidget(_wrap(StatusBadge(status: s, delayMinutes: 15)));
        expect(t.takeException(), isNull);
      });
    }

    testWidgets('onDark variant renders', (t) async {
      await t.pumpWidget(
          _wrap(const StatusBadge(status: 'boarding', onDark: true)));
      expect(t.takeException(), isNull);
    });
  });

  // ── EmptyState ────────────────────────────────────────────────────────────
  group('EmptyState', () {
    testWidgets('renders title and message', (t) async {
      await t.pumpWidget(_wrap(const EmptyState(
        icon: Icons.inbox,
        title: 'Nothing here',
        message: 'Check back later',
      )));
      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Check back later'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('renders with action widget', (t) async {
      await t.pumpWidget(_wrap(EmptyState(
        icon: Icons.inbox,
        title: 'Empty',
        action: PrimaryButton(label: 'Refresh', onPressed: () {}),
      )));
      expect(find.text('Refresh'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  // ── ErrorState ────────────────────────────────────────────────────────────
  group('ErrorState', () {
    testWidgets('renders message', (t) async {
      await t
          .pumpWidget(_wrap(const ErrorState(message: 'Network error')));
      expect(find.text('Network error'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('renders Try again button when onRetry provided', (t) async {
      await t
          .pumpWidget(_wrap(ErrorState(message: 'Oops', onRetry: () {})));
      expect(find.text('Try again'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  // ── LoadingState ──────────────────────────────────────────────────────────
  group('LoadingState', () {
    testWidgets('renders shimmer rows', (t) async {
      await t.pumpWidget(_wrap(const LoadingState(itemCount: 3)));
      expect(t.takeException(), isNull);
    });

    testWidgets('renders in dark mode', (t) async {
      await t.pumpWidget(_wrap(const LoadingState(), dark: true));
      expect(t.takeException(), isNull);
    });
  });

  // ── GradientHero ──────────────────────────────────────────────────────────
  group('GradientHero', () {
    testWidgets('renders child', (t) async {
      await t
          .pumpWidget(_wrap(const GradientHero(child: Text('Hero'))));
      expect(find.text('Hero'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('custom colors and height do not throw', (t) async {
      await t.pumpWidget(_wrap(const GradientHero(
        height: 150,
        colors: [Colors.blue, Colors.purple],
        child: SizedBox(),
      )));
      expect(t.takeException(), isNull);
    });
  });

  // ── InfoRow ───────────────────────────────────────────────────────────────
  group('InfoRow', () {
    testWidgets('renders label and value', (t) async {
      await t.pumpWidget(_wrap(const InfoRow(
        icon: Icons.place,
        label: 'Gate',
        value: 'B22',
      )));
      expect(find.text('Gate'), findsOneWidget);
      expect(find.text('B22'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  // ── GoldDivider ───────────────────────────────────────────────────────────
  group('GoldDivider', () {
    testWidgets('renders without error', (t) async {
      await t.pumpWidget(_wrap(const GoldDivider()));
      expect(t.takeException(), isNull);
    });

    testWidgets('renders in dark mode', (t) async {
      await t.pumpWidget(_wrap(const GoldDivider(), dark: true));
      expect(t.takeException(), isNull);
    });
  });

  // ── PrimaryButton ─────────────────────────────────────────────────────────
  group('PrimaryButton', () {
    testWidgets('renders label', (t) async {
      await t
          .pumpWidget(_wrap(PrimaryButton(label: 'Book', onPressed: () {})));
      expect(find.text('Book'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('loading state shows no label', (t) async {
      await t.pumpWidget(
          _wrap(const PrimaryButton(label: 'Book', loading: true)));
      expect(find.text('Book'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('icon variant renders', (t) async {
      await t.pumpWidget(_wrap(PrimaryButton(
        label: 'Search',
        icon: Icons.search,
        onPressed: () {},
      )));
      expect(find.text('Search'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  // ── SecondaryButton ───────────────────────────────────────────────────────
  group('SecondaryButton', () {
    testWidgets('renders label', (t) async {
      await t.pumpWidget(
          _wrap(SecondaryButton(label: 'Cancel', onPressed: () {})));
      expect(find.text('Cancel'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('loading state', (t) async {
      await t.pumpWidget(
          _wrap(const SecondaryButton(label: 'Cancel', loading: true)));
      expect(find.text('Cancel'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  // ── RatingStars ───────────────────────────────────────────────────────────
  group('RatingStars', () {
    testWidgets('renders 5 star icons', (t) async {
      await t.pumpWidget(_wrap(const RatingStars(rating: 3.5)));
      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_half), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  // ── CategoryFilterChips ───────────────────────────────────────────────────
  group('CategoryFilterChips', () {
    testWidgets('renders categories and highlights selected', (t) async {
      await t.pumpWidget(_wrap(CategoryFilterChips(
        categories: const ['Food', 'Shopping', 'Lounge'],
        selected: 'Shopping',
        onSelected: (_) {},
      )));
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  // ── SearchBarWidget ───────────────────────────────────────────────────────
  group('SearchBarWidget', () {
    testWidgets('renders hint text', (t) async {
      await t.pumpWidget(_wrap(SearchBarWidget(
        hint: 'Search venues',
        onChanged: (_) {},
      )));
      expect(find.text('Search venues'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('dark mode renders without error', (t) async {
      await t.pumpWidget(_wrap(
        SearchBarWidget(hint: 'Find', onChanged: (_) {}),
        dark: true,
      ));
      expect(t.takeException(), isNull);
    });
  });
}
