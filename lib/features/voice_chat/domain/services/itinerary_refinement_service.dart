import 'package:airport_nav/features/lounges/domain/entities/lounge.dart';
import 'package:airport_nav/features/shops/domain/entities/shop.dart';
import 'package:airport_nav/features/venues/domain/taxonomy/venue_taxonomy.dart';
import 'package:airport_nav/features/voice_chat/domain/entities/chat_message.dart';

/// What kind of edit the user is asking for.
sealed class RefinementIntent {
  const RefinementIntent();
}

/// "Undo", "revert", "go back".
class UndoIntent extends RefinementIntent {
  const UndoIntent();
}

/// "Start over", "scrap that and...", "new plan".
class NewPlanIntent extends RefinementIntent {
  const NewPlanIntent();
}

/// "30 minutes in the lounge instead of 45".
class ChangeDurationIntent extends RefinementIntent {
  final int stopIndex;
  final int newMinutes;
  const ChangeDurationIntent({required this.stopIndex, required this.newMinutes});
}

/// "Skip the coffee stop."
class RemoveStopIntent extends RefinementIntent {
  final int stopIndex;
  const RemoveStopIntent({required this.stopIndex});
}

/// "Add a cosmetics store between lunch and the gate."
class AddStopIntent extends RefinementIntent {
  /// Tag or category key the user is asking for.
  final String target;

  /// `null` means "append to the end". `i` means "insert after stops[i]".
  final int? insertAfterIndex;

  const AddStopIntent({required this.target, this.insertAfterIndex});
}

/// "I want something quick instead of a full restaurant."
class ReplaceStopIntent extends RefinementIntent {
  final int stopIndex;
  final String newTarget;
  const ReplaceStopIntent({required this.stopIndex, required this.newTarget});
}

/// Anything we can't classify as a refinement.
class UnknownRefinementIntent extends RefinementIntent {
  const UnknownRefinementIntent();
}

/// The output of a successful refinement.
class RefinementResult {
  final RoutePlan plan;
  final String confirmation;
  const RefinementResult({required this.plan, required this.confirmation});
}

/// Pure-Dart heuristic parser + applier for itinerary edits.
///
/// Given the *current* itinerary and a free-text user message, parse it
/// into a [RefinementIntent], then apply it to produce a new [RoutePlan]
/// plus a short confirmation line. The current plan is preserved as much
/// as possible — only the targeted stop(s) change.
class ItineraryRefinementService {
  static const _undoKeywords = [
    'undo',
    'revert',
    'go back',
    'rollback',
    'roll back',
    'scrap that',
    'never mind that',
    'nevermind that',
    'previous plan',
    'last change',
  ];

  static const _newPlanKeywords = [
    'start over',
    'from scratch',
    'new plan',
    'fresh plan',
    'reset plan',
    'forget all that',
    'start fresh',
  ];

  static const _removeKeywords = [
    'skip',
    'remove',
    'drop',
    'cancel',
    'without',
    "don't need",
    'dont need',
    'no need for',
    'forget the',
    'take out',
    'cut the',
  ];

  static const _addKeywords = [
    'add',
    'include',
    'stop by',
    'fit in',
    'squeeze in',
    'also want',
    'lets also',
    "let's also",
    'also a',
    'also add',
  ];

  static const _replaceKeywords = [
    'instead of',
    'rather than',
    'replace',
    'swap to',
    'swap with',
    'swap for',
    'change to',
    'switch to',
  ];

  static const _defaultStayMinutes = {
    'dining': 25,
    'duty_free': 15,
    'luxury': 20,
    'electronics': 15,
    'convenience': 10,
    'retail': 15,
    'lounge': 45,
  };

  // ───────────────────────────── Parse ──────────────────────────────

  RefinementIntent parse(String message, RoutePlan currentPlan) {
    final norm = message.toLowerCase().trim();
    if (norm.isEmpty) return const UnknownRefinementIntent();

    if (_containsAny(norm, _undoKeywords)) return const UndoIntent();
    if (_containsAny(norm, _newPlanKeywords)) return const NewPlanIntent();

    // Change duration — explicit minute count is a stronger signal than
    // "instead of", which often refers to the previous duration ("30 min
    // instead of 45"). So check this first.
    final durationMatch =
        RegExp(r'(\d+)\s*(?:minutes?|mins?|hrs?|hours?)').firstMatch(norm);
    if (durationMatch != null) {
      var minutes = int.parse(durationMatch.group(1)!);
      final unit = durationMatch.group(0)!;
      if (unit.contains('hr') || unit.contains('hour')) {
        minutes *= 60;
      }
      final stopIndex = _findReferencedStop(norm, currentPlan);
      if (stopIndex != null) {
        return ChangeDurationIntent(
            stopIndex: stopIndex, newMinutes: minutes);
      }
    }

    // Replace — "X instead of Y", "swap Y for X", etc.
    if (_containsAny(norm, _replaceKeywords)) {
      final replaceMarker = _firstHit(norm, _replaceKeywords)!;
      final beforeReplace = norm.substring(0, replaceMarker.start);
      final afterReplace = norm.substring(replaceMarker.end);

      final newTarget = _extractTarget(beforeReplace) ?? _extractTarget(norm);
      final stopIndex = _findReferencedStop(afterReplace, currentPlan) ??
          _findReferencedStop(norm, currentPlan);
      if (newTarget != null && stopIndex != null) {
        return ReplaceStopIntent(stopIndex: stopIndex, newTarget: newTarget);
      }
    }

    // Remove
    if (_containsAny(norm, _removeKeywords)) {
      final stopIndex = _findReferencedStop(norm, currentPlan);
      if (stopIndex != null) {
        return RemoveStopIntent(stopIndex: stopIndex);
      }
    }

    // Add (explicit verb + target)
    if (_containsAny(norm, _addKeywords)) {
      final target = _extractTarget(norm);
      if (target != null) {
        final insertAfter = _parseInsertPosition(norm, currentPlan);
        return AddStopIntent(target: target, insertAfterIndex: insertAfter);
      }
    }

    // Implicit add — message just mentions a category/tag/item with no
    // explicit verb but the user is clearly continuing the conversation
    // (we already have a plan). E.g. "also a coffee" → add coffee.
    final implicitTarget = _extractTarget(norm);
    if (implicitTarget != null) {
      final insertAfter = _parseInsertPosition(norm, currentPlan);
      return AddStopIntent(target: implicitTarget, insertAfterIndex: insertAfter);
    }

    return const UnknownRefinementIntent();
  }

  // ──────────────────────────── Apply ───────────────────────────────

  RefinementResult? apply(
    RefinementIntent intent,
    RoutePlan plan, {
    required List<Shop> shops,
    required List<Lounge> lounges,
  }) {
    switch (intent) {
      case ChangeDurationIntent(:final stopIndex, :final newMinutes):
        return _applyChangeDuration(plan, stopIndex, newMinutes);
      case RemoveStopIntent(:final stopIndex):
        return _applyRemove(plan, stopIndex);
      case AddStopIntent(:final target, :final insertAfterIndex):
        return _applyAdd(plan, target, insertAfterIndex,
            shops: shops, lounges: lounges);
      case ReplaceStopIntent(:final stopIndex, :final newTarget):
        return _applyReplace(plan, stopIndex, newTarget,
            shops: shops, lounges: lounges);
      case UndoIntent():
      case NewPlanIntent():
      case UnknownRefinementIntent():
        return null;
    }
  }

  RefinementResult _applyChangeDuration(
      RoutePlan plan, int stopIndex, int newMinutes) {
    final stops = [...plan.stops];
    final old = stops[stopIndex];
    stops[stopIndex] = old.copyWith(stayMinutes: newMinutes);
    final updated = plan.copyWith(
      stops: stops,
      totalMinutes: _sumMinutes(stops),
    );
    return RefinementResult(
      plan: updated,
      confirmation:
          'Got it — set ${old.name} to $newMinutes min (was ${old.stayMinutes}).',
    );
  }

  RefinementResult? _applyRemove(RoutePlan plan, int stopIndex) {
    if (plan.stops.length <= 1) {
      // Don't allow removing the last stop — it'd leave an empty plan.
      return RefinementResult(
        plan: plan,
        confirmation:
            "I'd leave you with an empty plan if I removed that. Try editing it instead.",
      );
    }
    final stops = [...plan.stops];
    final removed = stops.removeAt(stopIndex);
    // Carry the removed walk time forward so total walking remains plausible.
    if (stopIndex < stops.length) {
      stops[stopIndex] = stops[stopIndex].copyWith(
        walkMinutes: stops[stopIndex].walkMinutes + (removed.walkMinutes ~/ 2),
      );
    }
    final updated = plan.copyWith(
      stops: stops,
      totalMinutes: _sumMinutes(stops),
    );
    return RefinementResult(
      plan: updated,
      confirmation: 'Removed ${removed.name} from your route.',
    );
  }

  RefinementResult? _applyAdd(
    RoutePlan plan,
    String target,
    int? insertAfterIndex, {
    required List<Shop> shops,
    required List<Lounge> lounges,
  }) {
    final stop = _buildStopForTarget(target, shops: shops, lounges: lounges);
    if (stop == null) {
      return RefinementResult(
        plan: plan,
        confirmation:
            "I couldn't find a $target spot at this airport — want to try a different category?",
      );
    }
    if (plan.stops.any((s) => s.name == stop.name)) {
      return RefinementResult(
        plan: plan,
        confirmation: '${stop.name} is already in your plan.',
      );
    }

    final stops = [...plan.stops];
    final at = insertAfterIndex == null ? stops.length : insertAfterIndex + 1;
    stops.insert(at.clamp(0, stops.length), stop);
    final updated = plan.copyWith(
      stops: stops,
      totalMinutes: _sumMinutes(stops),
    );
    final placement =
        insertAfterIndex == null ? 'at the end' : 'after ${plan.stops[insertAfterIndex].name}';
    return RefinementResult(
      plan: updated,
      confirmation: 'Added ${stop.name} $placement.',
    );
  }

  RefinementResult? _applyReplace(
    RoutePlan plan,
    int stopIndex,
    String newTarget, {
    required List<Shop> shops,
    required List<Lounge> lounges,
  }) {
    final newStop = _buildStopForTarget(newTarget,
        shops: shops, lounges: lounges,
        excludeNames: plan.stops.map((s) => s.name).toSet());
    if (newStop == null) {
      return RefinementResult(
        plan: plan,
        confirmation:
            "I couldn't find a $newTarget spot to swap in. Want to try something else?",
      );
    }
    final stops = [...plan.stops];
    final old = stops[stopIndex];
    stops[stopIndex] = newStop.copyWith(walkMinutes: old.walkMinutes);
    final updated = plan.copyWith(
      stops: stops,
      totalMinutes: _sumMinutes(stops),
    );
    return RefinementResult(
      plan: updated,
      confirmation: 'Swapped ${old.name} for ${newStop.name}.',
    );
  }

  // ──────────────────────────── Helpers ─────────────────────────────

  bool _containsAny(String norm, List<String> needles) =>
      needles.any(norm.contains);

  Match? _firstHit(String norm, List<String> needles) {
    Match? best;
    int bestStart = norm.length;
    for (final n in needles) {
      final m = RegExp(RegExp.escape(n)).firstMatch(norm);
      if (m != null && m.start < bestStart) {
        best = m;
        bestStart = m.start;
      }
    }
    return best;
  }

  /// Try to map a fragment of a user message to one of the stops in the
  /// current plan. Matches (whole-word) by name, category/category-aliases,
  /// and any of the stop brand's tags' aliases.
  ///
  /// As a fallback, runs the fragment through [VenueTaxonomy.analyzeQuery]
  /// so loose references ("the burger stop") resolve to a dining stop even
  /// when the actual venue isn't a literal burger brand.
  int? _findReferencedStop(String fragment, RoutePlan plan) {
    final norm = fragment.toLowerCase();
    for (var i = 0; i < plan.stops.length; i++) {
      final s = plan.stops[i];
      if (_containsWord(norm, s.name.toLowerCase())) return i;

      final cat = VenueTaxonomy.categoryFor(s.category);
      if (cat != null) {
        final categoryWords = [
          cat.key.replaceAll('_', ' '),
          cat.label.toLowerCase(),
          ...cat.aliases,
        ];
        for (final cw in categoryWords) {
          if (cw.length >= 3 && _containsWord(norm, cw)) return i;
        }
      }

      final brand = VenueTaxonomy.findBrand(s.name);
      if (brand != null) {
        for (final tag in brand.tags) {
          final tagDef = VenueTaxonomy.tagFor(tag);
          if (tagDef == null) continue;
          final tagWords = [
            tag.replaceAll('_', ' '),
            ...tagDef.aliases,
          ];
          for (final tw in tagWords) {
            if (tw.length >= 3 && _containsWord(norm, tw)) return i;
          }
        }
      }
    }

    // Inferred fallback — if the fragment carries a category intent,
    // pick the first stop in that category.
    final inferred = VenueTaxonomy.analyzeQuery(fragment);
    if (inferred.category != null) {
      for (var i = 0; i < plan.stops.length; i++) {
        if (plan.stops[i].category == inferred.category) return i;
      }
    }
    return null;
  }

  /// Pull a category/tag key out of free-form text. Picks the *leftmost*
  /// tag-alias hit so explicit nouns ("cosmetics") win over tags inferred
  /// from brand-item matches ("japanese" via Fa-So-La's items list).
  String? _extractTarget(String fragment) {
    final norm = fragment.toLowerCase();

    String? bestTag;
    int bestPos = norm.length;
    for (final tagDef in VenueTaxonomy.tags) {
      final words = [
        tagDef.key.replaceAll('_', ' '),
        ...tagDef.aliases,
      ];
      for (final w in words) {
        if (w.length < 3) continue;
        final idx = norm.indexOf(w);
        if (idx >= 0 && idx < bestPos && _isWordBoundary(norm, idx, w.length)) {
          bestPos = idx;
          bestTag = tagDef.key;
        }
      }
    }
    if (bestTag != null) return bestTag;

    String? bestCategory;
    bestPos = norm.length;
    for (final catDef in VenueTaxonomy.categories) {
      final words = [
        catDef.key.replaceAll('_', ' '),
        catDef.label.toLowerCase(),
        ...catDef.aliases,
      ];
      for (final w in words) {
        if (w.length < 3) continue;
        final idx = norm.indexOf(w);
        if (idx >= 0 && idx < bestPos && _isWordBoundary(norm, idx, w.length)) {
          bestPos = idx;
          bestCategory = catDef.key;
        }
      }
    }
    return bestCategory;
  }

  /// Whole-word `contains`: "rest" must not match "restaurant".
  bool _containsWord(String haystack, String needle) {
    if (needle.isEmpty) return false;
    final idx = haystack.indexOf(needle);
    if (idx < 0) return false;
    return _isWordBoundary(haystack, idx, needle.length);
  }

  bool _isWordBoundary(String haystack, int idx, int length) {
    final before = idx == 0 ? ' ' : haystack[idx - 1];
    final endIdx = idx + length;
    final after = endIdx >= haystack.length ? ' ' : haystack[endIdx];
    return !RegExp(r'[a-z0-9]').hasMatch(before) &&
        !RegExp(r'[a-z0-9]').hasMatch(after);
  }

  /// "between X and Y" → after X (insert before Y).
  /// "after X" → after X.
  /// "before X" → before X (returns index − 1).
  int? _parseInsertPosition(String norm, RoutePlan plan) {
    final between =
        RegExp(r'between\s+([^,]+?)\s+and\s+([^,.]+)').firstMatch(norm);
    if (between != null) {
      final before = between.group(1)!;
      final firstIdx = _findReferencedStop(before, plan);
      if (firstIdx != null) return firstIdx;
    }

    final after = RegExp(r'after\s+([^,.]+)').firstMatch(norm);
    if (after != null) {
      final idx = _findReferencedStop(after.group(1)!, plan);
      if (idx != null) return idx;
    }

    final before = RegExp(r'before\s+([^,.]+)').firstMatch(norm);
    if (before != null) {
      final idx = _findReferencedStop(before.group(1)!, plan);
      if (idx != null) return idx - 1;
    }

    return null;
  }

  /// Build a fresh [RouteStop] for a tag/category target by picking the
  /// best-rated matching shop or lounge in the airport.
  RouteStop? _buildStopForTarget(
    String target, {
    required List<Shop> shops,
    required List<Lounge> lounges,
    Set<String> excludeNames = const {},
  }) {
    // Resolve target → category. If `target` is a tag, pull its primary
    // category; if it's a category key, use it directly.
    String? category;
    final tagDef = VenueTaxonomy.tagFor(target);
    if (tagDef != null && tagDef.categories.isNotEmpty) {
      category = tagDef.categories.first;
    }
    if (VenueTaxonomy.categoryFor(target) != null) {
      category = target;
    }

    // Lounge target → pick best-rated lounge.
    if (category == 'lounge' || target == 'lounge') {
      final candidates = lounges
          .where((l) => !excludeNames.contains(l.name))
          .toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));
      if (candidates.isEmpty) return null;
      final l = candidates.first;
      return RouteStop(
        name: l.name,
        category: 'lounge',
        style: l.style,
        floor: l.floor,
        location: '${l.terminal} - ${l.location}',
        walkMinutes: 5,
        stayMinutes: _defaultStayMinutes['lounge']!,
        description: 'Access: ${l.accessType}',
      );
    }

    // Shop target — first try venues whose brand catalog matches the
    // tag, then fall back to the category bucket.
    Iterable<Shop> shopMatches() {
      final byTag = shops.where((s) {
        if (excludeNames.contains(s.name)) return false;
        final brand = VenueTaxonomy.findBrand(s.name);
        return brand != null && brand.tags.contains(target);
      });
      if (byTag.isNotEmpty) return byTag;
      if (category != null) {
        return shops.where((s) =>
            s.category == category && !excludeNames.contains(s.name));
      }
      return const [];
    }

    final candidates = shopMatches().toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    if (candidates.isEmpty) return null;
    final s = candidates.first;
    final stayMin = _defaultStayMinutes[s.category] ?? 15;
    return RouteStop(
      name: s.name,
      category: s.category,
      style: s.style,
      floor: s.floor,
      location: '${s.terminal} - ${s.location}',
      walkMinutes: 5,
      stayMinutes: stayMin,
      description: s.description.length > 80
          ? '${s.description.substring(0, 80)}...'
          : s.description,
    );
  }

  int _sumMinutes(List<RouteStop> stops) =>
      stops.fold<int>(0, (sum, s) => sum + s.walkMinutes + s.stayMinutes);
}
