/// Venue taxonomy: the single source of truth for what kinds of venues
/// exist, what tags describe them, and how user queries map onto either.
///
/// Three layers:
///   - [VenueCategoryDef]: top-level bucket (food/dining, lounge, luxury…).
///   - [VenueTagDef]: subcategory keyword (burgers, sushi, streetwear…).
///   - [BrandDef]: known brand → category + tags + (optional) logo domain.
///
/// Adding a new venue type later means adding entries here — nothing in the
/// search service or UI should need to change.
library;

class VenueCategoryDef {
  final String key;
  final String label;
  final List<String> aliases;
  final List<String> defaultTags;

  const VenueCategoryDef({
    required this.key,
    required this.label,
    this.aliases = const [],
    this.defaultTags = const [],
  });
}

class VenueTagDef {
  final String key;
  final String label;
  final List<String> aliases;

  /// Categories where this tag is most relevant. Empty = applicable to any.
  final List<String> categories;

  const VenueTagDef({
    required this.key,
    required this.label,
    this.aliases = const [],
    this.categories = const [],
  });
}

class BrandDef {
  final String name;
  final List<String> aliases;
  final String category;
  final List<String> tags;

  /// Specific products / dishes / SKUs the brand is known for. Powers
  /// item-level search ("burger" → Shake Shack, "sushi" → Sushi Kyotatsu).
  final List<String> items;

  final String? domain;

  const BrandDef({
    required this.name,
    required this.category,
    required this.tags,
    this.items = const [],
    this.aliases = const [],
    this.domain,
  });
}

/// Query intent inferred from a free-text search.
class QueryIntent {
  final String? brand;
  final String? category;
  final Set<String> tags;
  final Set<String> items;
  final List<String> tokens;

  const QueryIntent({
    this.brand,
    this.category,
    this.tags = const {},
    this.items = const {},
    this.tokens = const [],
  });

  bool get isEmpty =>
      brand == null && category == null && tags.isEmpty && items.isEmpty;
}

class VenueTaxonomy {
  // ───────────────────────── Categories ─────────────────────────

  static const List<VenueCategoryDef> categories = [
    VenueCategoryDef(
      key: 'dining',
      label: 'Dining',
      aliases: ['food', 'eat', 'restaurant', 'meal', 'hungry', 'dine'],
    ),
    VenueCategoryDef(
      key: 'duty_free',
      label: 'Duty Free',
      aliases: ['duty free', 'duty-free', 'tax free', 'tax-free'],
    ),
    VenueCategoryDef(
      key: 'luxury',
      label: 'Luxury',
      aliases: ['luxury', 'high end', 'premium goods'],
    ),
    VenueCategoryDef(
      key: 'electronics',
      label: 'Electronics',
      aliases: ['electronics', 'tech', 'gadget', 'gadgets'],
    ),
    VenueCategoryDef(
      key: 'convenience',
      label: 'Convenience',
      aliases: ['convenience', 'kiosk', 'newsstand'],
    ),
    VenueCategoryDef(
      key: 'retail',
      label: 'Retail',
      aliases: ['retail', 'store', 'shopping', 'shop', 'apparel'],
    ),
    VenueCategoryDef(
      key: 'lounge',
      label: 'Lounge',
      aliases: ['lounge', 'relax', 'rest', 'club', 'wait'],
    ),
  ];

  // ─────────────────────────── Tags ─────────────────────────────
  // Tags are subcategories. They're shared across categories where useful
  // (e.g. "japanese" is meaningful for both dining and electronics).

  static const List<VenueTagDef> tags = [
    // Food / dining ------------------------------------------------
    VenueTagDef(
      key: 'burgers',
      label: 'Burgers',
      aliases: ['burger', 'burgers', 'hamburger', 'hamburgers', 'cheeseburger'],
      categories: ['dining'],
    ),
    VenueTagDef(
      key: 'fast_food',
      label: 'Fast Food',
      aliases: ['fast food', 'quick service', 'quick serve', 'qsr', 'on the go', 'quick', 'something quick'],
      categories: ['dining'],
    ),
    VenueTagDef(
      key: 'fine_dining',
      label: 'Fine Dining',
      aliases: ['fine dining', 'upscale', 'gourmet restaurant'],
      categories: ['dining'],
    ),
    VenueTagDef(
      key: 'american',
      label: 'American',
      aliases: ['american', 'usa', 'us style'],
    ),
    VenueTagDef(
      key: 'italian',
      label: 'Italian',
      aliases: ['italian', 'italy'],
      categories: ['dining'],
    ),
    VenueTagDef(
      key: 'pizza',
      label: 'Pizza',
      aliases: ['pizza', 'pizzeria'],
      categories: ['dining'],
    ),
    VenueTagDef(
      key: 'pasta',
      label: 'Pasta',
      aliases: ['pasta', 'spaghetti', 'noodle'],
      categories: ['dining'],
    ),
    VenueTagDef(
      key: 'asian',
      label: 'Asian',
      aliases: ['asian', 'oriental', 'east asian'],
      categories: ['dining'],
    ),
    VenueTagDef(
      key: 'japanese',
      label: 'Japanese',
      aliases: ['japanese', 'japan'],
    ),
    VenueTagDef(
      key: 'sushi',
      label: 'Sushi',
      aliases: ['sushi', 'sashimi', 'nigiri', 'maki'],
      categories: ['dining'],
    ),
    VenueTagDef(
      key: 'noodles',
      label: 'Noodles',
      aliases: ['noodles', 'ramen', 'udon', 'pho'],
      categories: ['dining'],
    ),
    VenueTagDef(
      key: 'coffee',
      label: 'Coffee',
      aliases: ['coffee', 'cafe', 'espresso', 'latte', 'cappuccino', 'caffeine'],
      categories: ['dining'],
    ),
    VenueTagDef(
      key: 'cafe',
      label: 'Cafe',
      aliases: ['cafe', 'café'],
      categories: ['dining'],
    ),
    VenueTagDef(
      key: 'pastries',
      label: 'Pastries',
      aliases: ['pastry', 'pastries', 'bakery', 'baked', 'macaron', 'macarons'],
      categories: ['dining'],
    ),
    VenueTagDef(
      key: 'french',
      label: 'French',
      aliases: ['french', 'france', 'parisian'],
    ),
    VenueTagDef(
      key: 'british',
      label: 'British',
      aliases: ['british', 'english'],
    ),
    VenueTagDef(
      key: 'irish',
      label: 'Irish',
      aliases: ['irish', 'ireland'],
      categories: ['dining'],
    ),
    VenueTagDef(
      key: 'pub',
      label: 'Pub',
      aliases: ['pub', 'beer', 'ale'],
      categories: ['dining'],
    ),
    VenueTagDef(
      key: 'singaporean',
      label: 'Singaporean',
      aliases: ['singaporean', 'singapore', 'peranakan'],
    ),
    VenueTagDef(
      key: 'middle_eastern',
      label: 'Middle Eastern',
      aliases: ['middle eastern', 'arab', 'arabic'],
    ),
    VenueTagDef(
      key: 'chocolate',
      label: 'Chocolate',
      aliases: ['chocolate', 'cocoa'],
    ),
    VenueTagDef(
      key: 'sweets',
      label: 'Sweets',
      aliases: ['sweet', 'sweets', 'dessert', 'desserts', 'candy'],
    ),
    VenueTagDef(
      key: 'gourmet',
      label: 'Gourmet',
      aliases: ['gourmet', 'deli', 'artisanal'],
      categories: ['dining'],
    ),

    // Duty free ---------------------------------------------------
    VenueTagDef(
      key: 'perfume',
      label: 'Perfume',
      aliases: ['perfume', 'fragrance', 'scent', 'cologne'],
      categories: ['duty_free', 'luxury'],
    ),
    VenueTagDef(
      key: 'spirits',
      label: 'Spirits',
      aliases: ['spirits', 'whisky', 'whiskey', 'vodka', 'gin', 'rum', 'liquor'],
      categories: ['duty_free'],
    ),
    VenueTagDef(
      key: 'wines',
      label: 'Wines',
      aliases: ['wine', 'wines', 'red wine', 'white wine'],
      categories: ['duty_free', 'dining'],
    ),
    VenueTagDef(
      key: 'champagne',
      label: 'Champagne',
      aliases: ['champagne', 'sparkling'],
      categories: ['duty_free'],
    ),
    VenueTagDef(
      key: 'tobacco',
      label: 'Tobacco',
      aliases: ['tobacco', 'cigarette', 'cigar'],
      categories: ['duty_free'],
    ),
    VenueTagDef(
      key: 'sake',
      label: 'Sake',
      aliases: ['sake'],
      categories: ['duty_free', 'dining'],
    ),

    // Luxury / fashion --------------------------------------------
    VenueTagDef(
      key: 'jewelry',
      label: 'Jewelry',
      aliases: ['jewelry', 'jewellery', 'ring', 'rings', 'necklace'],
      categories: ['luxury'],
    ),
    VenueTagDef(
      key: 'diamonds',
      label: 'Diamonds',
      aliases: ['diamond', 'diamonds'],
      categories: ['luxury'],
    ),
    VenueTagDef(
      key: 'gold',
      label: 'Gold',
      aliases: ['gold'],
      categories: ['luxury'],
    ),
    VenueTagDef(
      key: 'fashion',
      label: 'Fashion',
      aliases: ['fashion', 'designer', 'couture', 'apparel', 'clothing', 'clothes'],
      categories: ['luxury', 'retail'],
    ),
    VenueTagDef(
      key: 'leather',
      label: 'Leather',
      aliases: ['leather', 'bag', 'handbag', 'purse', 'wallet'],
      categories: ['luxury', 'retail'],
    ),
    VenueTagDef(
      key: 'cosmetics',
      label: 'Cosmetics',
      aliases: ['cosmetics', 'makeup', 'beauty', 'skincare'],
      categories: ['duty_free', 'luxury', 'retail'],
    ),
    VenueTagDef(
      key: 'streetwear',
      label: 'Streetwear',
      aliases: ['streetwear', 'urban', 'street wear'],
      categories: ['retail', 'luxury'],
    ),
    VenueTagDef(
      key: 'casual_wear',
      label: 'Casual Wear',
      aliases: ['casual wear', 'casual clothing', 'basics', 'essentials'],
      categories: ['retail'],
    ),
    VenueTagDef(
      key: 'department_store',
      label: 'Department Store',
      aliases: ['department store'],
      categories: ['luxury', 'retail'],
    ),

    // Electronics -------------------------------------------------
    VenueTagDef(
      key: 'phones',
      label: 'Phones',
      aliases: ['phone', 'phones', 'smartphone', 'iphone', 'mobile'],
      categories: ['electronics'],
    ),
    VenueTagDef(
      key: 'tablets',
      label: 'Tablets',
      aliases: ['tablet', 'tablets', 'ipad'],
      categories: ['electronics'],
    ),
    VenueTagDef(
      key: 'computers',
      label: 'Computers',
      aliases: ['laptop', 'macbook', 'computer', 'computers'],
      categories: ['electronics'],
    ),
    VenueTagDef(
      key: 'headphones',
      label: 'Headphones',
      aliases: ['headphone', 'headphones', 'earbuds', 'airpods', 'audio'],
      categories: ['electronics'],
    ),
    VenueTagDef(
      key: 'chargers',
      label: 'Chargers',
      aliases: ['charger', 'chargers', 'charging', 'power bank', 'adapter'],
      categories: ['electronics'],
    ),
    VenueTagDef(
      key: 'cameras',
      label: 'Cameras',
      aliases: ['camera', 'cameras', 'lens'],
      categories: ['electronics'],
    ),
    VenueTagDef(
      key: 'gaming',
      label: 'Gaming',
      aliases: ['gaming', 'console', 'game'],
      categories: ['electronics'],
    ),

    // Convenience / souvenirs -------------------------------------
    VenueTagDef(
      key: 'news',
      label: 'News',
      aliases: ['news', 'newspaper', 'newspapers'],
      categories: ['convenience'],
    ),
    VenueTagDef(
      key: 'magazines',
      label: 'Magazines',
      aliases: ['magazine', 'magazines'],
      categories: ['convenience'],
    ),
    VenueTagDef(
      key: 'books',
      label: 'Books',
      aliases: ['book', 'books', 'bestsellers', 'novel'],
      categories: ['convenience', 'electronics'],
    ),
    VenueTagDef(
      key: 'snacks',
      label: 'Snacks',
      aliases: ['snack', 'snacks'],
      categories: ['convenience'],
    ),
    VenueTagDef(
      key: 'souvenirs',
      label: 'Souvenirs',
      aliases: ['souvenir', 'souvenirs', 'memento', 'mementos'],
      categories: ['convenience', 'retail'],
    ),
    VenueTagDef(
      key: 'gifts',
      label: 'Gifts',
      aliases: ['gift', 'gifts', 'present', 'presents'],
    ),
    VenueTagDef(
      key: 'music',
      label: 'Music',
      aliases: ['music', 'cd', 'vinyl'],
      categories: ['electronics', 'retail'],
    ),

    // Lounge ------------------------------------------------------
    VenueTagDef(
      key: 'airline_lounge',
      label: 'Airline Lounge',
      aliases: ['airline lounge'],
      categories: ['lounge'],
    ),
    VenueTagDef(
      key: 'priority_pass',
      label: 'Priority Pass',
      aliases: ['priority pass', 'priority-pass', 'loungekey'],
      categories: ['lounge'],
    ),
    VenueTagDef(
      key: 'pay_per_use',
      label: 'Pay Per Use',
      aliases: ['pay per use', 'walk in', 'walk-in', 'pay at door'],
      categories: ['lounge'],
    ),
    VenueTagDef(
      key: 'business_class',
      label: 'Business Class',
      aliases: ['business class', 'biz class'],
      categories: ['lounge'],
    ),
    VenueTagDef(
      key: 'first_class',
      label: 'First Class',
      aliases: ['first class'],
      categories: ['lounge'],
    ),
    VenueTagDef(
      key: 'shower',
      label: 'Shower',
      aliases: ['shower', 'showers'],
      categories: ['lounge'],
    ),
    VenueTagDef(
      key: 'sleep_pods',
      label: 'Sleep Pods',
      aliases: ['sleep pod', 'sleep pods', 'nap'],
      categories: ['lounge'],
    ),
    VenueTagDef(
      key: 'spa',
      label: 'Spa',
      aliases: ['spa', 'massage'],
      categories: ['lounge'],
    ),
    VenueTagDef(
      key: 'business_center',
      label: 'Business Center',
      aliases: ['business center', 'workspace'],
      categories: ['lounge'],
    ),
    VenueTagDef(
      key: 'wifi',
      label: 'Wi-Fi',
      aliases: ['wifi', 'wi-fi', 'internet'],
      categories: ['lounge'],
    ),
    VenueTagDef(
      key: 'bar',
      label: 'Bar',
      aliases: ['bar', 'cocktail'],
      categories: ['lounge', 'dining'],
    ),
  ];

  // ─────────────────────────── Brands ────────────────────────────

  static const List<BrandDef> brands = [
    // Dining brands
    BrandDef(
      name: 'Shake Shack',
      category: 'dining',
      tags: ['burgers', 'american', 'fast_food'],
      items: ['burger', 'shackburger', 'cheeseburger', 'fries', 'milkshake', 'shake', 'hot dog'],
      domain: 'shakeshack.com',
    ),
    BrandDef(
      name: 'Starbucks',
      category: 'dining',
      tags: ['coffee', 'cafe', 'american'],
      items: ['coffee', 'latte', 'cappuccino', 'espresso', 'frappuccino', 'tea', 'pastry', 'sandwich'],
      domain: 'starbucks.com',
    ),
    BrandDef(
      name: "McDonald's",
      aliases: ['mcdonalds', 'mc donalds', 'mcd'],
      category: 'dining',
      tags: ['burgers', 'american', 'fast_food'],
      items: ['burger', 'big mac', 'cheeseburger', 'fries', 'mcnuggets', 'chicken nuggets', 'breakfast', 'mcmuffin'],
      domain: 'mcdonalds.com',
    ),
    BrandDef(
      name: 'Burger King',
      aliases: ['burger king', 'bk'],
      category: 'dining',
      tags: ['burgers', 'american', 'fast_food'],
      items: ['burger', 'whopper', 'cheeseburger', 'fries', 'chicken nuggets'],
      domain: 'bk.com',
    ),
    BrandDef(
      name: 'KFC',
      aliases: ['kentucky fried chicken'],
      category: 'dining',
      tags: ['fast_food', 'american'],
      items: ['fried chicken', 'chicken', 'wings', 'fries'],
      domain: 'kfc.com',
    ),
    BrandDef(
      name: 'Subway',
      category: 'dining',
      tags: ['fast_food', 'american'],
      items: ['sandwich', 'sub', 'salad', 'wrap'],
      domain: 'subway.com',
    ),
    BrandDef(
      name: 'Gordon Ramsay Plane Food',
      aliases: ['gordon ramsay'],
      category: 'dining',
      tags: ['british', 'fine_dining'],
      items: ['steak', 'burger', 'fish and chips', 'salad', 'dessert', 'wine'],
      domain: 'gordonramsayrestaurants.com',
    ),
    BrandDef(
      name: 'Ladurée',
      aliases: ['laduree'],
      category: 'dining',
      tags: ['french', 'pastries', 'cafe'],
      items: ['macaron', 'pastry', 'tart', 'eclair', 'tea', 'coffee'],
      domain: 'laduree.com',
    ),
    BrandDef(
      name: 'The Irish Village',
      aliases: ['irish village'],
      category: 'dining',
      tags: ['irish', 'pub'],
      items: ['fish and chips', 'beer', 'guinness', 'burger', 'shepherds pie'],
      domain: 'theirishvillage.com',
    ),
    BrandDef(
      name: 'Ghirardelli Chocolate',
      aliases: ['ghirardelli'],
      category: 'convenience',
      tags: ['chocolate', 'sweets', 'american', 'gifts'],
      items: ['chocolate', 'truffle', 'hot cocoa', 'sundae'],
      domain: 'ghirardelli.com',
    ),
    BrandDef(
      name: 'Sushi Kyotatsu',
      category: 'dining',
      tags: ['sushi', 'japanese', 'asian', 'fine_dining'],
      items: ['sushi', 'sashimi', 'nigiri', 'maki', 'roll', 'miso soup', 'sake'],
    ),
    BrandDef(
      name: 'Tokyo Banana',
      category: 'convenience',
      tags: ['japanese', 'pastries', 'sweets', 'souvenirs', 'gifts'],
      items: ['banana cake', 'sponge cake', 'pastry', 'sweets'],
    ),
    BrandDef(
      name: 'Bengawan Solo',
      category: 'dining',
      tags: ['singaporean', 'asian', 'pastries', 'gifts'],
      items: ['pandan cake', 'kueh', 'pastry', 'cake'],
    ),
    BrandDef(
      name: 'Bateel Dates',
      aliases: ['bateel'],
      category: 'retail',
      tags: ['middle_eastern', 'sweets', 'gifts'],
      items: ['dates', 'chocolate dates', 'gift box'],
      domain: 'bateel.com',
    ),
    BrandDef(
      name: 'Napa Farms Market',
      category: 'dining',
      tags: ['american', 'wines', 'gourmet'],
      items: ['sandwich', 'salad', 'wine', 'cheese', 'coffee'],
    ),

    // Duty Free brands
    BrandDef(
      name: 'Duty Free Americas',
      category: 'duty_free',
      tags: ['spirits', 'perfume', 'cosmetics', 'tobacco'],
      items: ['whisky', 'vodka', 'perfume', 'lipstick', 'cigarettes'],
      domain: 'dutyfreeamericas.com',
    ),
    BrandDef(
      name: 'DFS Duty Free',
      aliases: ['dfs'],
      category: 'duty_free',
      tags: ['spirits', 'perfume', 'cosmetics'],
      items: ['whisky', 'vodka', 'perfume', 'lipstick', 'sunglasses'],
      domain: 'dfs.com',
    ),
    BrandDef(
      name: 'DFS Wines & Spirits',
      category: 'duty_free',
      tags: ['wines', 'spirits', 'champagne'],
      items: ['wine', 'whisky', 'champagne', 'cognac', 'gin'],
      domain: 'dfs.com',
    ),
    BrandDef(
      name: 'World Duty Free',
      category: 'duty_free',
      tags: ['spirits', 'perfume', 'cosmetics', 'tobacco'],
      items: ['whisky', 'gin', 'perfume', 'lipstick', 'cigarettes'],
      domain: 'worlddutyfree.com',
    ),
    BrandDef(
      name: 'Buy Paris Duty Free',
      category: 'duty_free',
      tags: ['wines', 'champagne', 'perfume', 'french', 'gourmet'],
      items: ['wine', 'champagne', 'perfume', 'macaron', 'chocolate'],
      domain: 'parisaeroport.fr',
    ),
    BrandDef(
      name: 'Dubai Duty Free',
      category: 'duty_free',
      tags: ['spirits', 'perfume', 'gold', 'tobacco'],
      items: ['whisky', 'perfume', 'gold', 'sunglasses', 'cigarettes', 'chocolate'],
      domain: 'dubaidutyfree.com',
    ),
    BrandDef(
      name: 'Fa-So-La Duty Free',
      aliases: ['fasola', 'fa so la'],
      category: 'duty_free',
      tags: ['japanese', 'cosmetics', 'sake', 'spirits'],
      items: ['sake', 'whisky', 'cosmetics', 'matcha'],
    ),

    // Luxury brands
    BrandDef(
      name: 'Tiffany & Co.',
      aliases: ['tiffany', 'tiffanys'],
      category: 'luxury',
      tags: ['jewelry', 'diamonds', 'american'],
      items: ['ring', 'necklace', 'bracelet', 'earrings', 'diamond'],
      domain: 'tiffany.com',
    ),
    BrandDef(
      name: 'Burberry',
      category: 'retail',
      tags: ['fashion', 'british', 'leather'],
      items: ['trench coat', 'scarf', 'handbag', 'wallet', 'shirt'],
      domain: 'burberry.com',
    ),
    BrandDef(
      name: 'Hermès',
      aliases: ['hermes'],
      category: 'luxury',
      tags: ['fashion', 'leather', 'french'],
      items: ['scarf', 'handbag', 'belt', 'wallet', 'perfume'],
      domain: 'hermes.com',
    ),
    BrandDef(
      name: 'Charles & Keith',
      aliases: ['charles and keith'],
      category: 'retail',
      tags: ['fashion', 'leather', 'singaporean'],
      items: ['handbag', 'shoes', 'wallet', 'belt'],
      domain: 'charleskeith.com',
    ),
    BrandDef(
      name: 'Gold & Diamond Park',
      aliases: ['gold and diamond'],
      category: 'luxury',
      tags: ['jewelry', 'gold', 'diamonds'],
      items: ['gold', 'ring', 'necklace', 'diamond', 'bracelet'],
    ),
    BrandDef(
      name: 'Benefit Cosmetics',
      aliases: ['benefit'],
      category: 'retail',
      tags: ['cosmetics', 'american'],
      items: ['mascara', 'lipstick', 'foundation', 'brow pencil', 'blush'],
      domain: 'benefitcosmetics.com',
    ),
    BrandDef(
      name: 'Harrods',
      category: 'luxury',
      tags: ['fashion', 'british', 'department_store', 'gourmet'],
      items: ['handbag', 'scarf', 'tea', 'gift box', 'perfume'],
      domain: 'harrods.com',
    ),
    BrandDef(
      name: 'Gucci',
      category: 'luxury',
      tags: ['fashion', 'leather', 'italian'],
      items: ['handbag', 'wallet', 'belt', 'shoes', 'sunglasses'],
      domain: 'gucci.com',
    ),
    BrandDef(
      name: 'Prada',
      category: 'luxury',
      tags: ['fashion', 'leather', 'italian'],
      items: ['handbag', 'wallet', 'belt', 'shoes', 'sunglasses'],
      domain: 'prada.com',
    ),

    // Electronics brands
    BrandDef(
      name: 'InMotion Entertainment',
      aliases: ['inmotion'],
      category: 'electronics',
      tags: ['headphones', 'chargers'],
      items: ['headphones', 'earbuds', 'charger', 'power bank', 'travel adapter'],
      domain: 'inmotionstores.com',
    ),
    BrandDef(
      name: 'Best Buy Express',
      aliases: ['best buy', 'bestbuy'],
      category: 'electronics',
      tags: ['headphones', 'chargers'],
      items: ['headphones', 'earbuds', 'charger', 'cable', 'phone case'],
      domain: 'bestbuy.com',
    ),
    BrandDef(
      name: 'Samsung Experience Store',
      aliases: ['samsung'],
      category: 'electronics',
      tags: ['phones', 'tablets'],
      items: ['phone', 'galaxy', 'smartphone', 'tablet', 'smartwatch', 'earbuds'],
      domain: 'samsung.com',
    ),
    BrandDef(
      name: 'Apple Store',
      aliases: ['apple'],
      category: 'electronics',
      tags: ['phones', 'tablets', 'computers', 'headphones'],
      items: ['iphone', 'ipad', 'macbook', 'airpods', 'apple watch', 'phone case'],
      domain: 'apple.com',
    ),
    BrandDef(
      name: 'Akihabara Electronics',
      aliases: ['akihabara'],
      category: 'electronics',
      tags: ['gaming', 'cameras', 'japanese'],
      items: ['camera', 'lens', 'gaming console', 'controller', 'gadget'],
    ),
    BrandDef(
      name: 'Tech Shop by InMotion',
      category: 'electronics',
      tags: ['headphones', 'chargers'],
      items: ['headphones', 'charger', 'power bank', 'cable'],
      domain: 'inmotionstores.com',
    ),
    BrandDef(
      name: 'FNAC',
      category: 'electronics',
      tags: ['books', 'music', 'french'],
      items: ['book', 'cd', 'vinyl', 'tablet', 'headphones'],
      domain: 'fnac.com',
    ),

    // Convenience / retail brands
    BrandDef(
      name: 'Hudson News',
      aliases: ['hudson'],
      category: 'convenience',
      tags: ['news', 'magazines', 'snacks', 'books', 'souvenirs'],
      items: ['newspaper', 'magazine', 'book', 'snack', 'water', 'souvenir'],
      domain: 'hudsongroup.com',
    ),
    BrandDef(
      name: 'WHSmith',
      aliases: ['wh smith', 'whs'],
      category: 'convenience',
      tags: ['news', 'magazines', 'books', 'snacks', 'british'],
      items: ['newspaper', 'magazine', 'book', 'snack', 'water'],
      domain: 'whsmith.co.uk',
    ),
    BrandDef(
      name: 'Relay',
      category: 'convenience',
      tags: ['news', 'magazines', 'books', 'snacks'],
      items: ['newspaper', 'magazine', 'book', 'snack', 'water'],
      domain: 'relay.com',
    ),
    BrandDef(
      name: "See's Candies",
      aliases: ['sees candies', 'sees'],
      category: 'retail',
      tags: ['chocolate', 'sweets', 'american', 'gifts'],
      items: ['chocolate', 'truffle', 'lollipop', 'gift box'],
      domain: 'sees.com',
    ),
    BrandDef(
      name: 'Discover Singapore',
      category: 'convenience',
      tags: ['souvenirs', 'gifts', 'singaporean'],
      items: ['souvenir', 'merlion', 'tea', 'craft'],
    ),
    BrandDef(
      name: 'Uniqlo',
      category: 'retail',
      tags: ['fashion', 'casual_wear', 'japanese'],
      items: ['t shirt', 'jeans', 'jacket', 'sweater', 'socks', 'underwear'],
      domain: 'uniqlo.com',
    ),

    // Lounges
    BrandDef(
      name: 'Admirals Club',
      category: 'lounge',
      tags: ['airline_lounge'],
      domain: 'aa.com',
    ),
    BrandDef(
      name: 'Centurion Lounge',
      aliases: ['amex centurion'],
      category: 'lounge',
      tags: ['business_center'],
      domain: 'americanexpress.com',
    ),
    BrandDef(
      name: 'Star Alliance Lounge',
      category: 'lounge',
      tags: ['airline_lounge'],
      domain: 'staralliance.com',
    ),
    BrandDef(
      name: 'Plaza Premium Lounge',
      aliases: ['plaza premium'],
      category: 'lounge',
      tags: ['priority_pass', 'pay_per_use'],
      domain: 'plazapremiumlounge.com',
    ),
    BrandDef(
      name: 'British Airways Galleries First',
      aliases: ['ba galleries', 'british airways lounge'],
      category: 'lounge',
      tags: ['airline_lounge', 'first_class', 'british'],
      domain: 'britishairways.com',
    ),
    BrandDef(
      name: 'Air France La Premiere Lounge',
      aliases: ['air france lounge', 'la premiere'],
      category: 'lounge',
      tags: ['airline_lounge', 'first_class', 'french'],
      domain: 'airfrance.com',
    ),
    BrandDef(
      name: 'Icare Lounge',
      category: 'lounge',
      tags: ['priority_pass', 'pay_per_use'],
    ),
    BrandDef(
      name: 'Emirates Business Class Lounge',
      aliases: ['emirates lounge'],
      category: 'lounge',
      tags: ['airline_lounge', 'business_class'],
      domain: 'emirates.com',
    ),
    BrandDef(
      name: 'Marhaba Lounge',
      aliases: ['marhaba'],
      category: 'lounge',
      tags: ['pay_per_use', 'priority_pass'],
      domain: 'marhabaservices.com',
    ),
    BrandDef(
      name: 'SilverKris Lounge',
      aliases: ['silverkris', 'singapore airlines lounge'],
      category: 'lounge',
      tags: ['airline_lounge', 'business_class'],
      domain: 'singaporeair.com',
    ),
    BrandDef(
      name: 'SATS Premier Lounge',
      aliases: ['sats lounge'],
      category: 'lounge',
      tags: ['priority_pass', 'pay_per_use'],
      domain: 'sats.com.sg',
    ),
    BrandDef(
      name: 'Sakura Lounge',
      aliases: ['jal lounge'],
      category: 'lounge',
      tags: ['airline_lounge', 'japanese'],
      domain: 'jal.co.jp',
    ),
    BrandDef(
      name: 'IASS Executive Lounge',
      aliases: ['iass'],
      category: 'lounge',
      tags: ['priority_pass', 'pay_per_use', 'japanese'],
    ),
    BrandDef(
      name: 'Qantas First Lounge',
      aliases: ['qantas lounge'],
      category: 'lounge',
      tags: ['airline_lounge', 'first_class'],
      domain: 'qantas.com',
    ),
  ];

  // ─────────────────────── Indexes (lazy) ────────────────────────

  static final Map<String, VenueCategoryDef> _categoryByKey = {
    for (final c in categories) c.key: c,
  };

  static final Map<String, VenueTagDef> _tagByKey = {
    for (final t in tags) t.key: t,
  };

  /// Brand name lookup keyed by *normalized* brand name and aliases.
  static final Map<String, BrandDef> _brandByNorm = (() {
    final m = <String, BrandDef>{};
    for (final b in brands) {
      m[_normalize(b.name)] = b;
      for (final a in b.aliases) {
        m[_normalize(a)] = b;
      }
    }
    return m;
  })();

  /// All known items (normalized) → list of brands that sell each item.
  /// Sorted longest-first so "fish and chips" beats "fish".
  static final List<MapEntry<String, List<BrandDef>>> _itemMatches = (() {
    final byItem = <String, List<BrandDef>>{};
    for (final b in brands) {
      for (final item in b.items) {
        byItem.putIfAbsent(_normalize(item), () => []).add(b);
      }
    }
    final list = byItem.entries.toList();
    list.sort((a, b) => b.key.length.compareTo(a.key.length));
    return list;
  })();

  /// Tag aliases sorted longest-first so multi-word aliases ("fast food")
  /// win over their single-word substrings ("food") when scanning a query.
  static final List<MapEntry<String, VenueTagDef>> _tagAliases = (() {
    final list = <MapEntry<String, VenueTagDef>>[];
    for (final t in tags) {
      list.add(MapEntry(_normalize(t.key.replaceAll('_', ' ')), t));
      for (final a in t.aliases) {
        list.add(MapEntry(_normalize(a), t));
      }
    }
    list.sort((a, b) => b.key.length.compareTo(a.key.length));
    return list;
  })();

  static final List<MapEntry<String, VenueCategoryDef>> _categoryAliases = (() {
    final list = <MapEntry<String, VenueCategoryDef>>[];
    for (final c in categories) {
      list.add(MapEntry(_normalize(c.key.replaceAll('_', ' ')), c));
      list.add(MapEntry(_normalize(c.label), c));
      for (final a in c.aliases) {
        list.add(MapEntry(_normalize(a), c));
      }
    }
    list.sort((a, b) => b.key.length.compareTo(a.key.length));
    return list;
  })();

  // ───────────────────────── Public API ──────────────────────────

  static VenueCategoryDef? categoryFor(String key) => _categoryByKey[key];

  static VenueTagDef? tagFor(String key) => _tagByKey[key];

  static String labelForCategory(String key) =>
      _categoryByKey[key]?.label ?? key;

  static String labelForTag(String key) =>
      _tagByKey[key]?.label ?? _humanize(key);

  static BrandDef? findBrand(String name) => _brandByNorm[_normalize(name)];

  static String? logoDomainFor(String brandName) =>
      findBrand(brandName)?.domain;

  /// Items the venue is known to sell — derived from the brand catalog.
  /// Returns an empty list when the venue isn't a recognized brand.
  static List<String> deriveItemsForVenue({required String name}) {
    final brand = findBrand(name);
    if (brand == null) return const [];
    return List.unmodifiable(brand.items);
  }

  /// Tags that should be attached to a venue based on its brand, category
  /// defaults, and any free-form hints (e.g. lounge amenities).
  static List<String> deriveTagsForVenue({
    required String name,
    required String category,
    required String style,
    List<String> extraHints = const [],
  }) {
    final out = <String>{};

    // Brand-driven tags.
    final brand = findBrand(name);
    if (brand != null) {
      out.addAll(brand.tags);
    }

    // Category default tags.
    final cat = _categoryByKey[category];
    if (cat != null) {
      out.addAll(cat.defaultTags);
    }

    // Style → tag mapping where a style happens to match a known tag key.
    if (_tagByKey.containsKey(style)) {
      out.add(style);
    }

    // Extra hints (lounge amenities, etc.) — only keep ones we recognize.
    for (final h in extraHints) {
      if (_tagByKey.containsKey(h)) {
        out.add(h);
      }
    }

    return out.toList()..sort();
  }

  /// Parse a free-text search query into a structured intent.
  ///
  /// Detection layers run in order: brand → item → tag → category. Each
  /// layer enriches the intent rather than replacing it. Categories/tags
  /// can be inferred from a matched item's brand, so a query like "fries"
  /// (no tag/category alias on its own) still maps to dining.
  static QueryIntent analyzeQuery(String query) {
    final norm = _normalize(query);
    if (norm.isEmpty) return const QueryIntent();

    // 1. Brand match — user typed a recognizable brand name.
    final brand = _findBrandInQuery(norm);

    final inferredTags = <String>{};
    final inferredItems = <String>{};
    String? inferredCategory;

    if (brand != null) {
      inferredCategory = brand.category;
      inferredTags.addAll(brand.tags);
    }

    // 2. Item match — query word appears in a brand's items list.
    //    Also harvest category + tags from those brands.
    for (final entry in _itemMatches) {
      if (_containsWord(norm, entry.key)) {
        inferredItems.add(entry.key);
        for (final brandWithItem in entry.value) {
          inferredTags.addAll(brandWithItem.tags);
          inferredCategory ??= brandWithItem.category;
        }
      }
    }

    // 3. Tag aliases — direct subcategory keywords.
    for (final entry in _tagAliases) {
      if (entry.key.isEmpty) continue;
      if (_containsWord(norm, entry.key)) {
        inferredTags.add(entry.value.key);
      }
    }

    // 4. Category aliases — only when nothing stronger has fired.
    if (inferredCategory == null) {
      for (final entry in _categoryAliases) {
        if (entry.key.isEmpty) continue;
        if (_containsWord(norm, entry.key)) {
          inferredCategory = entry.value.key;
          break;
        }
      }
    }

    // Fallback: pull a category from a matched tag's primary category.
    if (inferredCategory == null && inferredTags.isNotEmpty) {
      for (final tagKey in inferredTags) {
        final tag = _tagByKey[tagKey];
        if (tag != null && tag.categories.isNotEmpty) {
          inferredCategory = tag.categories.first;
          break;
        }
      }
    }

    return QueryIntent(
      brand: brand?.name,
      category: inferredCategory,
      tags: inferredTags,
      items: inferredItems,
      tokens: norm.split(' ').where((t) => t.isNotEmpty).toList(),
    );
  }

  // ───────────────────────── Internals ───────────────────────────

  static BrandDef? _findBrandInQuery(String normalizedQuery) {
    // Prefer the longest brand-key that fits inside the query.
    BrandDef? best;
    int bestLen = 0;
    for (final entry in _brandByNorm.entries) {
      if (entry.key.isEmpty) continue;
      if (_containsWord(normalizedQuery, entry.key) &&
          entry.key.length > bestLen) {
        best = entry.value;
        bestLen = entry.key.length;
      }
    }
    return best;
  }

  /// Word-boundary aware contains so "rest" doesn't match "restaurant" but
  /// "fast food" does match "i need fast food now".
  static bool _containsWord(String haystack, String needle) {
    if (needle.isEmpty) return false;
    final idx = haystack.indexOf(needle);
    if (idx < 0) return false;
    final before = idx == 0 ? ' ' : haystack[idx - 1];
    final endIdx = idx + needle.length;
    final after = endIdx >= haystack.length ? ' ' : haystack[endIdx];
    bool isBoundary(String c) => !RegExp(r'[a-z0-9]').hasMatch(c);
    return isBoundary(before) && isBoundary(after);
  }

  static String _normalize(String s) {
    final lower = s.toLowerCase();
    final stripped = lower.replaceAll(RegExp(r"[^a-z0-9]+"), ' ');
    return stripped.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String _humanize(String key) {
    return key
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
