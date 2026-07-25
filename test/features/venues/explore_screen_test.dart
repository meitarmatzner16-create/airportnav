import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:airport_nav/features/venues/presentation/screens/explore_screen.dart';

void main() {
  testWidgets('Explore shows title, filter chips, and a walk-time result bar',
      (t) async {
    await t.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ExploreScreen())));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Explore'), findsWidgets);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Lounge'), findsOneWidget);
    expect(find.textContaining('walk time'), findsOneWidget);
  });
}
