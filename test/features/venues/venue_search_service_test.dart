import 'package:flutter_test/flutter_test.dart';
import 'package:airport_nav/features/venues/domain/entities/venue.dart';
import 'package:airport_nav/features/venues/domain/services/venue_search_service.dart';
import 'package:airport_nav/features/venues/domain/taxonomy/venue_taxonomy.dart';

/// Builds a minimal Venue for tests. Tags AND items are derived through the
/// taxonomy the same way the production providers do it, so the brand
/// catalog is exercised here too.
Venue _v({
  required String id,
  required String name,
  required String category,
  String style = 'casual',
  double rating = 4.0,
  List<String> extraHints = const [],
  VenueType type = VenueType.shop,
}) {
  return Venue(
    id: id,
    name: name,
    category: category,
    style: style,
    tags: VenueTaxonomy.deriveTagsForVenue(
      name: name,
      category: category,
      style: style,
      extraHints: extraHints,
    ),
    items: VenueTaxonomy.deriveItemsForVenue(name: name),
    airportCode: 'TST',
    terminal: 'T1',
    floor: 1,
    location: 'Gate 1',
    rating: rating,
    openingHours: '24/7',
    description: '',
    type: type,
  );
}

void main() {
  group('VenueTaxonomy.deriveTagsForVenue', () {
    test('Shake Shack gets burgers/american/fast_food via brand catalog', () {
      final tags = VenueTaxonomy.deriveTagsForVenue(
        name: 'Shake Shack',
        category: 'dining',
        style: 'street_vibes',
      );
      expect(tags, containsAll(['burgers', 'american', 'fast_food']));
    });

    test('Lounge amenities flow through as tags', () {
      final tags = VenueTaxonomy.deriveTagsForVenue(
        name: 'Centurion Lounge',
        category: 'lounge',
        style: 'luxury',
        extraHints: ['wifi', 'shower', 'bogus_amenity'],
      );
      expect(tags, contains('wifi'));
      expect(tags, contains('shower'));
      expect(tags, isNot(contains('bogus_amenity')));
    });

    test('Unknown brand still produces an empty-but-valid tag set', () {
      final tags = VenueTaxonomy.deriveTagsForVenue(
        name: 'Some Random Cafe',
        category: 'dining',
        style: 'casual',
      );
      expect(tags, isA<List<String>>());
    });
  });

  group('VenueTaxonomy.analyzeQuery', () {
    test('Brand match sets brand + category + tags', () {
      final intent = VenueTaxonomy.analyzeQuery("McDonald's");
      expect(intent.brand, "McDonald's");
      expect(intent.category, 'dining');
      expect(intent.tags, containsAll(['burgers', 'american', 'fast_food']));
    });

    test('Brand alias without apostrophe still matches', () {
      final intent = VenueTaxonomy.analyzeQuery('mcdonalds');
      expect(intent.brand, "McDonald's");
    });

    test('Category alias "food" infers dining', () {
      final intent = VenueTaxonomy.analyzeQuery('food');
      expect(intent.category, 'dining');
    });

    test('Tag alias "sushi" infers tag + dining category', () {
      final intent = VenueTaxonomy.analyzeQuery('sushi');
      expect(intent.tags, contains('sushi'));
      expect(intent.category, 'dining');
    });

    test('Multi-word tag alias "fast food" wins over single word "food"', () {
      final intent = VenueTaxonomy.analyzeQuery('fast food please');
      expect(intent.tags, contains('fast_food'));
      expect(intent.category, 'dining');
    });

    test('Unknown query returns empty intent', () {
      final intent = VenueTaxonomy.analyzeQuery('zxzxzxzx');
      expect(intent.isEmpty, isTrue);
    });
  });

  group('VenueSearchService.search', () {
    final venues = <Venue>[
      _v(id: '1', name: 'Shake Shack', category: 'dining', style: 'street_vibes', rating: 4.5),
      _v(id: '2', name: 'Starbucks', category: 'dining', style: 'casual', rating: 4.1),
      _v(id: '3', name: 'Burberry', category: 'retail', style: 'luxury', rating: 4.6),
      _v(id: '4', name: 'Sushi Kyotatsu', category: 'dining', style: 'fancy', rating: 4.5),
      _v(id: '5', name: 'Uniqlo', category: 'retail', style: 'casual', rating: 4.3),
      _v(id: '6', name: 'Apple Store', category: 'electronics', style: 'fancy', rating: 4.7),
      _v(
        id: '7',
        name: 'Centurion Lounge',
        category: 'lounge',
        style: 'luxury',
        rating: 4.7,
        extraHints: ['wifi', 'shower', 'spa'],
        type: VenueType.lounge,
      ),
    ];

    const service = VenueSearchService();

    test('Empty query returns no matches and no suggestions', () {
      final result = service.search('', venues);
      expect(result.matches, isEmpty);
      expect(result.suggestions, isEmpty);
    });

    test('Exact name match goes into matches', () {
      final result = service.search('Starbucks', venues);
      expect(result.matches.map((v) => v.id), contains('2'));
    });

    test("McDonald's not in airport → suggests Shake Shack first", () {
      final result = service.search("McDonald's", venues);
      expect(result.matches, isEmpty);
      expect(result.intent.brand, "McDonald's");
      expect(result.suggestions, isNotEmpty);
      // Shake Shack shares burgers + american + fast_food → top suggestion.
      expect(result.suggestions.first.venue.id, '1');
      expect(
        result.suggestions.first.matchedTags,
        containsAll(['burgers', 'american', 'fast_food']),
      );
    });

    test('"sushi" matches Sushi Kyotatsu by name and infers dining', () {
      final result = service.search('sushi', venues);
      expect(result.matches.map((v) => v.id), contains('4'));
      expect(result.intent.tags, contains('sushi'));
      expect(result.intent.category, 'dining');
    });

    test('Tag alias "sashimi" → suggests Sushi Kyotatsu purely by tag', () {
      final result = service.search('sashimi', venues);
      expect(result.matches, isEmpty);
      expect(result.suggestions, isNotEmpty);
      expect(result.suggestions.first.venue.id, '4');
      expect(result.suggestions.first.matchedTags, contains('sushi'));
    });

    test('Category alias "food" suggests dining venues only', () {
      final result = service.search('food', venues);
      expect(result.matches, isEmpty);
      final categories =
          result.suggestions.map((s) => s.venue.category).toSet();
      expect(categories, {'dining'});
    });

    test('Unknown query yields no suggestions', () {
      final result = service.search('zxzxzxzx', venues);
      expect(result.matches, isEmpty);
      expect(result.suggestions, isEmpty);
    });

    test('Suggestions exclude exact name matches', () {
      final result = service.search('Starbucks', venues);
      final matchIds = result.matches.map((v) => v.id).toSet();
      final suggestionIds = result.suggestions.map((s) => s.venue.id).toSet();
      expect(matchIds.intersection(suggestionIds), isEmpty);
    });

    test('"casual wear" → Uniqlo first (its tag), Burberry below it', () {
      final result = service.search('casual wear', venues);
      expect(result.matches, isEmpty);
      expect(result.suggestions, isNotEmpty);
      expect(result.suggestions.first.venue.id, '5');
      expect(result.suggestions.first.matchedTags, contains('casual_wear'));
    });

    test('Suggestion limit is respected', () {
      const limited = VenueSearchService(suggestionLimit: 2);
      final result = limited.search('food', venues);
      expect(result.suggestions.length, lessThanOrEqualTo(2));
    });
  });

  group('Item-level search', () {
    final venues = <Venue>[
      _v(id: '1', name: 'Shake Shack', category: 'dining', rating: 4.5),
      _v(id: '2', name: 'Starbucks', category: 'dining', rating: 4.1),
      _v(id: '3', name: 'Sushi Kyotatsu', category: 'dining', rating: 4.5),
      _v(id: '4', name: 'Apple Store', category: 'electronics', rating: 4.7),
      _v(id: '5', name: 'Hudson News', category: 'convenience', rating: 3.8),
    ];

    const service = VenueSearchService();

    test('"burger" finds Shake Shack via item match', () {
      final result = service.search('burger', venues);
      expect(result.matches, isEmpty);
      expect(result.intent.items, contains('burger'));
      expect(result.suggestions, isNotEmpty);
      expect(result.suggestions.first.venue.id, '1');
      expect(result.suggestions.first.matchedItems, contains('burger'));
    });

    test('"sashimi" matches Sushi Kyotatsu by both tag and item', () {
      final result = service.search('sashimi', venues);
      expect(result.matches, isEmpty);
      expect(result.suggestions.first.venue.id, '3');
      expect(result.suggestions.first.matchedItems, contains('sashimi'));
    });

    test('"airpods" → Apple Store via item match', () {
      final result = service.search('airpods', venues);
      expect(result.matches, isEmpty);
      expect(result.suggestions, isNotEmpty);
      expect(result.suggestions.first.venue.id, '4');
      expect(result.suggestions.first.matchedItems, contains('airpods'));
    });

    test('Item-only query without tag/category match still infers dining', () {
      // "fries" isn't itself a tag or category alias, but McDonald's-style
      // brands list it as an item — so the search infers the dining category.
      final result = service.search('fries', venues);
      expect(result.intent.category, 'dining');
      expect(result.suggestions, isNotEmpty);
      expect(result.suggestions.first.venue.id, '1'); // Shake Shack
    });

    test('Items beat tags in scoring — venue selling the item wins', () {
      // "coffee" matches Starbucks's items AND Ladurée's items (Ladurée
      // isn't in this fixture). Among present venues, Starbucks should
      // outrank dining venues that only share the dining category.
      final result = service.search('coffee', venues);
      expect(result.matches, isEmpty);
      expect(result.suggestions.first.venue.id, '2'); // Starbucks
      expect(result.suggestions.first.matchedItems, contains('coffee'));
    });
  });
}
