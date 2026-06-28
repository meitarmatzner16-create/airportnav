import 'package:airport_nav/features/venues/domain/entities/venue.dart';
import 'package:airport_nav/features/venues/domain/taxonomy/venue_taxonomy.dart';

/// Pure-Dart search engine for venues.
///
/// Match layers (each enriches the result rather than replacing it):
///   1. Name match → goes into [matches] verbatim.
///   2. Item match → "burger", "sushi", "fries" — strongest similarity weight.
///   3. Tag match → "burgers" tag, "italian" tag, etc.
///   4. Category match → "dining", "luxury", etc.
///
/// Scoring is deliberately simple and tunable:
///   - exact item overlap: +4 each
///   - category overlap: +2
///   - tag overlap: +1 each
///   - rating tiebreaker: +0.1 × rating
class VenueSearchService {
  final int suggestionLimit;

  /// Minimum score to qualify as a suggestion. With the default scoring,
  /// 1.0 means "must match a category, a tag, or an item".
  final double suggestionThreshold;

  const VenueSearchService({
    this.suggestionLimit = 8,
    this.suggestionThreshold = 1.0,
  });

  VenueSearchResult search(String query, List<Venue> venues) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return VenueSearchResult(
        query: query,
        intent: const QueryIntent(),
        matches: const [],
        suggestions: const [],
      );
    }

    final intent = VenueTaxonomy.analyzeQuery(trimmed);
    final matches = _findNameMatches(trimmed, venues);
    final matchedIds = matches.map((v) => v.id).toSet();
    final suggestions = _rankSuggestions(intent, venues, exclude: matchedIds);

    return VenueSearchResult(
      query: query,
      intent: intent,
      matches: matches,
      suggestions: suggestions,
    );
  }

  // ────────────────────────── Internals ──────────────────────────

  List<Venue> _findNameMatches(String query, List<Venue> venues) {
    final q = query.toLowerCase();
    return venues
        .where((v) => v.name.toLowerCase().contains(q))
        .toList(growable: false);
  }

  List<ScoredVenue> _rankSuggestions(
    QueryIntent intent,
    List<Venue> venues, {
    required Set<String> exclude,
  }) {
    if (intent.isEmpty) return const [];

    final scored = <ScoredVenue>[];
    for (final v in venues) {
      if (exclude.contains(v.id)) continue;
      final scoredVenue = _scoreVenue(v, intent);
      if (scoredVenue.score >= suggestionThreshold) {
        scored.add(scoredVenue);
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    if (scored.length > suggestionLimit) {
      return scored.sublist(0, suggestionLimit);
    }
    return scored;
  }

  ScoredVenue _scoreVenue(Venue venue, QueryIntent intent) {
    double score = 0;
    final matchedTags = <String>{};
    final matchedItems = <String>{};

    // Item match — strongest signal: the venue literally sells this thing.
    for (final item in intent.items) {
      if (venue.items.contains(item)) {
        score += 4.0;
        matchedItems.add(item);
      }
    }

    final categoryMatched =
        intent.category != null && venue.category == intent.category;
    if (categoryMatched) score += 2.0;

    for (final tag in intent.tags) {
      if (venue.tags.contains(tag)) {
        score += 1.0;
        matchedTags.add(tag);
      }
    }

    // Rating tiebreaker.
    score += venue.rating * 0.1;

    return ScoredVenue(
      venue: venue,
      score: score,
      categoryMatched: categoryMatched,
      matchedTags: matchedTags,
      matchedItems: matchedItems,
    );
  }
}

class VenueSearchResult {
  final String query;
  final QueryIntent intent;
  final List<Venue> matches;
  final List<ScoredVenue> suggestions;

  const VenueSearchResult({
    required this.query,
    required this.intent,
    required this.matches,
    required this.suggestions,
  });

  bool get hasNameMatch => matches.isNotEmpty;
  bool get hasSuggestions => suggestions.isNotEmpty;
  bool get hasIntent => !intent.isEmpty;

  List<Venue> get suggestionVenues =>
      suggestions.map((s) => s.venue).toList(growable: false);
}

class ScoredVenue {
  final Venue venue;
  final double score;
  final Set<String> matchedTags;
  final Set<String> matchedItems;
  final bool categoryMatched;

  const ScoredVenue({
    required this.venue,
    required this.score,
    required this.matchedTags,
    required this.matchedItems,
    required this.categoryMatched,
  });
}
