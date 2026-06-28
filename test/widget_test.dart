import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:airport_nav/app.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: AirportNavApp()),
    );
    await tester.pump();
    expect(find.text('AirportNav'), findsOneWidget);
  });
}
