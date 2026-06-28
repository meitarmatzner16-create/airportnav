import 'package:flutter_test/flutter_test.dart';
import 'package:airport_nav/features/lounges/data/datasources/lounge_mock_datasource.dart';
import 'package:airport_nav/features/shops/data/datasources/shop_mock_datasource.dart';
import 'package:airport_nav/features/voice_chat/domain/entities/chat_message.dart';
import 'package:airport_nav/features/voice_chat/domain/services/itinerary_refinement_service.dart';
import 'package:airport_nav/features/voice_chat/domain/services/route_planner_service.dart';

/// Build a real route plan from the seeded mock data so tests exercise the
/// same pipeline production code does.
RoutePlan _seedPlan(String airportCode, String query) {
  final shops =
      ShopMockDatasource.shops.where((s) => s.airportCode == airportCode).toList();
  final lounges = LoungeMockDatasource.lounges
      .where((l) => l.airportCode == airportCode)
      .toList();
  final plan = RoutePlannerService().generateRoute(
    userQuery: query,
    availableShops: shops,
    availableLounges: lounges,
  );
  expect(plan, isNotNull, reason: 'seed query "$query" must produce a plan');
  return plan!;
}

void main() {
  final service = ItineraryRefinementService();

  // JFK has Shake Shack (dining/burgers) at T4 and Centurion Lounge at T4.
  final jfkShops =
      ShopMockDatasource.shops.where((s) => s.airportCode == 'JFK').toList();
  final jfkLounges = LoungeMockDatasource.lounges
      .where((l) => l.airportCode == 'JFK')
      .toList();

  group('parse', () {
    test('"undo" → UndoIntent', () {
      final plan = _seedPlan('JFK', 'burger and lounge');
      final intent = service.parse('undo that', plan);
      expect(intent, isA<UndoIntent>());
    });

    test('"start over" → NewPlanIntent', () {
      final plan = _seedPlan('JFK', 'burger and lounge');
      final intent = service.parse("let's start over from scratch", plan);
      expect(intent, isA<NewPlanIntent>());
    });

    test(
        'change duration: "30 minutes in the lounge instead of 45" → ChangeDurationIntent',
        () {
      final plan = _seedPlan('JFK', 'burger and lounge');
      final loungeIdx =
          plan.stops.indexWhere((s) => s.category == 'lounge');
      expect(loungeIdx, isNot(-1), reason: 'seed plan must include a lounge');

      final intent = service.parse(
        "actually, I'll spend only 30 minutes in the lounge instead of 45",
        plan,
      );
      expect(intent, isA<ChangeDurationIntent>());
      final c = intent as ChangeDurationIntent;
      expect(c.stopIndex, loungeIdx);
      expect(c.newMinutes, 30);
    });

    test('"skip the coffee stop" → RemoveStopIntent for Starbucks', () {
      // LAX has Starbucks (coffee tag) — skip it.
      final plan = _seedPlan('LAX', 'coffee and luxury bags');
      final coffeeIdx =
          plan.stops.indexWhere((s) => s.name == 'Starbucks');
      expect(coffeeIdx, isNot(-1));

      final intent = service.parse('skip the coffee stop', plan);
      expect(intent, isA<RemoveStopIntent>());
      expect((intent as RemoveStopIntent).stopIndex, coffeeIdx);
    });

    test(
        '"add a cosmetics store between lunch and the gate" → AddStopIntent with insert after the dining stop',
        () {
      final plan = _seedPlan('SFO', 'burger and electronics');
      final intent = service.parse(
        'add a cosmetics store between burger and electronics',
        plan,
      );
      expect(intent, isA<AddStopIntent>());
      final a = intent as AddStopIntent;
      expect(a.target, 'cosmetics');
      // "between burger and electronics" → after the burger (dining) stop.
      final diningIdx =
          plan.stops.indexWhere((s) => s.category == 'dining');
      expect(a.insertAfterIndex, diningIdx);
    });

    test(
        '"something quick instead of a full restaurant" → ReplaceStopIntent (fast_food → dining)',
        () {
      final plan = _seedPlan('LAX', 'burger and lounge');
      final diningIdx =
          plan.stops.indexWhere((s) => s.category == 'dining');
      expect(diningIdx, isNot(-1));

      final intent = service.parse(
        'I want something quick instead of a full restaurant',
        plan,
      );
      expect(intent, isA<ReplaceStopIntent>());
      final r = intent as ReplaceStopIntent;
      expect(r.stopIndex, diningIdx);
      expect(r.newTarget, 'fast_food');
    });
  });

  group('apply', () {
    test('ChangeDuration recomputes total minutes', () {
      final plan = _seedPlan('JFK', 'burger and lounge');
      final loungeIdx =
          plan.stops.indexWhere((s) => s.category == 'lounge');
      final originalTotal = plan.totalMinutes;
      final originalStay = plan.stops[loungeIdx].stayMinutes;

      final result = service.apply(
        ChangeDurationIntent(stopIndex: loungeIdx, newMinutes: 30),
        plan,
        shops: jfkShops,
        lounges: jfkLounges,
      );
      expect(result, isNotNull);
      expect(result!.plan.stops[loungeIdx].stayMinutes, 30);
      expect(result.plan.totalMinutes, originalTotal - originalStay + 30);
      expect(result.confirmation, contains('30 min'));
    });

    test('Remove drops the stop and shrinks total minutes', () {
      final plan = _seedPlan('JFK', 'burger and lounge');
      final origLen = plan.stops.length;
      final result = service.apply(
        RemoveStopIntent(stopIndex: 0),
        plan,
        shops: jfkShops,
        lounges: jfkLounges,
      );
      expect(result, isNotNull);
      expect(result!.plan.stops.length, origLen - 1);
      expect(result.plan.totalMinutes, lessThan(plan.totalMinutes));
    });

    test('Add inserts a new stop at the requested position', () {
      final plan = _seedPlan('SFO', 'burger and electronics');
      final beforeLen = plan.stops.length;
      final diningIdx =
          plan.stops.indexWhere((s) => s.category == 'dining');

      final result = service.apply(
        AddStopIntent(target: 'cosmetics', insertAfterIndex: diningIdx),
        plan,
        shops: ShopMockDatasource.shops
            .where((s) => s.airportCode == 'SFO')
            .toList(),
        lounges: LoungeMockDatasource.lounges
            .where((l) => l.airportCode == 'SFO')
            .toList(),
      );
      expect(result, isNotNull);
      expect(result!.plan.stops.length, beforeLen + 1);
      // The inserted stop should be at diningIdx + 1.
      final insertedAt = diningIdx + 1;
      expect(result.plan.stops[insertedAt].name, 'Benefit Cosmetics');
    });

    test('Replace swaps in a quick-service venue', () {
      final plan = _seedPlan('LAX', 'burger and lounge');
      final diningIdx =
          plan.stops.indexWhere((s) => s.category == 'dining');

      final result = service.apply(
        ReplaceStopIntent(stopIndex: diningIdx, newTarget: 'fast_food'),
        plan,
        shops: ShopMockDatasource.shops
            .where((s) => s.airportCode == 'LAX')
            .toList(),
        lounges: LoungeMockDatasource.lounges
            .where((l) => l.airportCode == 'LAX')
            .toList(),
      );
      expect(result, isNotNull);
      // LAX's fast_food brand is McDonald's.
      expect(result!.plan.stops[diningIdx].name, "McDonald's");
      expect(result.confirmation, contains('Swapped'));
    });

    test('Apply returns null for non-applicable intents', () {
      final plan = _seedPlan('JFK', 'burger and lounge');
      expect(
        service.apply(
          const UndoIntent(),
          plan,
          shops: jfkShops,
          lounges: jfkLounges,
        ),
        isNull,
      );
      expect(
        service.apply(
          const NewPlanIntent(),
          plan,
          shops: jfkShops,
          lounges: jfkLounges,
        ),
        isNull,
      );
    });

    test('Refinements are immutable — original plan is unchanged', () {
      final plan = _seedPlan('JFK', 'burger and lounge');
      final loungeIdx =
          plan.stops.indexWhere((s) => s.category == 'lounge');
      final originalLoungeStay = plan.stops[loungeIdx].stayMinutes;

      service.apply(
        ChangeDurationIntent(stopIndex: loungeIdx, newMinutes: 30),
        plan,
        shops: jfkShops,
        lounges: jfkLounges,
      );

      expect(plan.stops[loungeIdx].stayMinutes, originalLoungeStay,
          reason: 'original plan should not mutate');
    });
  });
}
