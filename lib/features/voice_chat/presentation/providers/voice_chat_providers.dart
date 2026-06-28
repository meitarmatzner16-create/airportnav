import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:airport_nav/features/voice_chat/domain/entities/chat_message.dart';
import 'package:airport_nav/features/voice_chat/domain/services/itinerary_refinement_service.dart';
import 'package:airport_nav/features/voice_chat/domain/services/route_planner_service.dart';
import 'package:airport_nav/features/shops/presentation/providers/shop_providers.dart';
import 'package:airport_nav/features/lounges/presentation/providers/lounge_providers.dart';

final routePlannerServiceProvider = Provider<RoutePlannerService>((ref) {
  return RoutePlannerService();
});

final itineraryRefinementServiceProvider =
    Provider<ItineraryRefinementService>((ref) {
  return ItineraryRefinementService();
});

final voiceChatAirportProvider = StateProvider<String>((ref) => 'JFK');

final voiceChatMessagesProvider =
    StateNotifierProvider<VoiceChatNotifier, List<ChatMessage>>((ref) {
  return VoiceChatNotifier(ref);
});

final isListeningProvider = StateProvider<bool>((ref) => false);

/// Live derived view of the most recent itinerary in memory. Watching this
/// from widgets gives them a single "current plan" handle without having
/// to reach into the notifier.
final currentItineraryProvider = Provider<RoutePlan?>((ref) {
  final messages = ref.watch(voiceChatMessagesProvider);
  for (var i = messages.length - 1; i >= 0; i--) {
    final plan = messages[i].routePlan;
    if (plan != null) return plan;
  }
  return null;
});

/// Whether the user has at least one earlier itinerary state to revert to.
final canUndoItineraryProvider = Provider<bool>((ref) {
  final messages = ref.watch(voiceChatMessagesProvider);
  var seen = 0;
  for (final m in messages) {
    if (m.routePlan != null) {
      seen++;
      if (seen >= 2) return true;
    }
  }
  return false;
});

class VoiceChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;

  VoiceChatNotifier(this._ref) : super([]) {
    _addGreeting();
  }

  // ─────────────────────────── Public API ────────────────────────────

  void sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    state = [...state, _userMsg(trimmed)];

    final currentPlan = _findCurrentPlan();
    if (currentPlan == null) {
      _generateNewPlan(trimmed);
      return;
    }

    final refinement = _ref.read(itineraryRefinementServiceProvider);
    final intent = refinement.parse(trimmed, currentPlan);

    switch (intent) {
      case UndoIntent():
        _applyUndo();
      case NewPlanIntent():
        _generateNewPlan(trimmed, announceReset: true);
      case UnknownRefinementIntent():
        // Fall back to a fresh plan only if it actually contains a
        // routable request; otherwise tell the user we didn't follow.
        _generateNewPlan(trimmed);
      case ChangeDurationIntent() ||
            RemoveStopIntent() ||
            AddStopIntent() ||
            ReplaceStopIntent():
        _applyRefinement(intent, currentPlan);
    }
  }

  /// Imperative undo — used by the explicit "Undo" UI affordance.
  void undo() => _applyUndo();

  void resetChat() {
    _addGreeting();
  }

  // ──────────────────────────── Internals ────────────────────────────

  void _addGreeting() {
    final airportCode = _ref.read(voiceChatAirportProvider);
    final service = _ref.read(routePlannerServiceProvider);
    state = [
      ChatMessage(
        id: 'greeting',
        text: service.getGreeting(airportCode),
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ];
  }

  ChatMessage _userMsg(String text) => ChatMessage(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      );

  ChatMessage _botMsg(String text, {RoutePlan? plan}) => ChatMessage(
        id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
        routePlan: plan,
      );

  RoutePlan? _findCurrentPlan() {
    for (var i = state.length - 1; i >= 0; i--) {
      final p = state[i].routePlan;
      if (p != null) return p;
    }
    return null;
  }

  RoutePlan? _findPreviousPlan() {
    var seen = 0;
    for (var i = state.length - 1; i >= 0; i--) {
      final p = state[i].routePlan;
      if (p != null) {
        seen++;
        if (seen == 2) return p;
      }
    }
    return null;
  }

  void _applyRefinement(RefinementIntent intent, RoutePlan currentPlan) {
    final airportCode = _ref.read(voiceChatAirportProvider);
    final shops = _ref.read(shopsByAirportProvider(airportCode));
    final lounges = _ref.read(loungesByAirportProvider(airportCode));
    final refinement = _ref.read(itineraryRefinementServiceProvider);

    final result = refinement.apply(
      intent,
      currentPlan,
      shops: shops,
      lounges: lounges,
    );

    if (result == null) {
      state = [
        ...state,
        _botMsg(
          "I didn't quite follow that — could you rephrase the change?",
        ),
      ];
      return;
    }

    state = [
      ...state,
      _botMsg(result.confirmation, plan: result.plan),
    ];
  }

  void _applyUndo() {
    final previous = _findPreviousPlan();
    if (previous == null) {
      state = [
        ...state,
        _botMsg('Nothing to undo yet — this is the only plan so far.'),
      ];
      return;
    }
    state = [
      ...state,
      _botMsg('Reverted to the previous plan.', plan: previous),
    ];
  }

  void _generateNewPlan(String userQuery, {bool announceReset = false}) {
    final airportCode = _ref.read(voiceChatAirportProvider);
    final planner = _ref.read(routePlannerServiceProvider);
    final shops = _ref.read(shopsByAirportProvider(airportCode));
    final lounges = _ref.read(loungesByAirportProvider(airportCode));

    final plan = planner.generateRoute(
      userQuery: userQuery,
      availableShops: shops,
      availableLounges: lounges,
    );

    if (plan == null) {
      state = [...state, _botMsg(planner.getNoResultsMessage())];
      return;
    }

    final intro = announceReset
        ? 'Starting fresh. ${planner.getRouteIntro(plan)}'
        : planner.getRouteIntro(plan);

    state = [...state, _botMsg(intro, plan: plan)];
  }
}
