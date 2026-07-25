import 'package:airport_nav/features/offers/domain/entities/offer.dart';

class OfferMockDatasource {
  List<Offer> getAllOffers() {
    final now = DateTime.now();
    final pastMonth = now.subtract(const Duration(days: 30));
    final twoMonthsAhead = now.add(const Duration(days: 60));
    final oneMonthAhead = now.add(const Duration(days: 30));
    final twoWeeksAhead = now.add(const Duration(days: 14));
    // ignore: unused_local_variable
    final oneWeekAhead = now.add(const Duration(days: 7));
    final threeDaysAhead = now.add(const Duration(days: 3));

    return [
      // --- JFK Offers ---
      Offer(
        id: 'offer-001',
        title: '20% off at Duty Free Americas',
        merchant: 'Duty Free Americas',
        description:
            'Enjoy 20% off on all fragrances, cosmetics, and spirits at Duty Free Americas. Wide selection of premium brands available.',
        discount: '20% OFF',
        category: 'duty_free',
        airportCode: 'JFK',
        promoCode: 'DFA20JFK',
        imageUrl: 'https://images.unsplash.com/photo-duty-free',
        validFrom: pastMonth,
        validUntil: oneMonthAhead,
        termsAndConditions:
            'Valid on in-store purchases only. Cannot be combined with other offers. Minimum purchase of \$50 required. One use per customer.',
      ),
      Offer(
        id: 'offer-002',
        title: 'Lounge Access from \$29',
        merchant: 'Plaza Premium Lounge',
        description:
            'Relax before your flight with premium lounge access. Includes complimentary food, beverages, Wi-Fi, and shower facilities.',
        discount: 'FROM \$29',
        category: 'lounge',
        airportCode: 'JFK',
        imageUrl: 'https://images.unsplash.com/photo-airport-lounge',
        validFrom: pastMonth,
        validUntil: twoMonthsAhead,
        termsAndConditions:
            'Subject to availability. Walk-in rate applies. Children under 2 free. Maximum stay 3 hours.',
      ),
      Offer(
        id: 'offer-003',
        title: 'Free Upgrade to Large Meal',
        merchant: 'Shake Shack',
        description:
            'Get a free upgrade to a large meal with any burger purchase at Shake Shack JFK Terminal 4.',
        discount: 'FREE UPGRADE',
        category: 'dining',
        airportCode: 'JFK',
        imageUrl: 'https://images.unsplash.com/photo-burger',
        validFrom: now.subtract(const Duration(days: 10)),
        validUntil: twoWeeksAhead,
        termsAndConditions:
            'Valid at JFK Terminal 4 location only. One per customer per visit. Cannot be combined with other promotions.',
      ),
      Offer(
        id: 'offer-004',
        title: '15% Off Travel Accessories',
        merchant: 'InMotion Entertainment',
        description:
            'Save 15% on headphones, adapters, chargers, and travel pillows at InMotion stores.',
        discount: '15% OFF',
        category: 'shopping',
        airportCode: 'JFK',
        promoCode: 'TRAVEL15',
        imageUrl: 'https://images.unsplash.com/photo-travel-accessories',
        validFrom: pastMonth,
        validUntil: oneMonthAhead,
        termsAndConditions:
            'Excludes Apple products and sale items. Valid on full-price items only.',
      ),

      // --- Airline-specific offers ---
      // American Airlines
      Offer(
        id: 'offer-aa-001',
        title: 'AAdvantage Members: Free Lounge',
        merchant: 'Admirals Club',
        description:
            'Complimentary Admirals Club access for AAdvantage members flying American Airlines today. Includes premium snacks, drinks, and Wi-Fi.',
        discount: 'FREE ACCESS',
        category: 'lounge',
        airportCode: 'JFK',
        airline: 'American Airlines',
        imageUrl: 'https://images.unsplash.com/photo-airline-lounge',
        validFrom: pastMonth,
        validUntil: twoMonthsAhead,
        termsAndConditions:
            'Valid for same-day American Airlines passengers only. Show boarding pass at entry.',
      ),
      Offer(
        id: 'offer-aa-002',
        title: '25% Off Duty Free for AA Flyers',
        merchant: 'DFS Group',
        description:
            'American Airlines passengers get 25% off all perfumes and skincare at DFS. Show your boarding pass.',
        discount: '25% OFF',
        category: 'duty_free',
        airportCode: 'JFK',
        airline: 'American Airlines',
        promoCode: 'AAFLY25',
        imageUrl: 'https://images.unsplash.com/photo-perfume-shop',
        validFrom: pastMonth,
        validUntil: oneMonthAhead,
        termsAndConditions:
            'Show American Airlines boarding pass. Valid on full-price items. One per passenger.',
      ),
      Offer(
        id: 'offer-aa-003',
        title: 'Free Coffee at Starbucks',
        merchant: 'Starbucks',
        description:
            'American Airlines passengers enjoy a free tall coffee at any JFK Starbucks. Just show your boarding pass.',
        discount: 'FREE COFFEE',
        category: 'dining',
        airportCode: 'JFK',
        airline: 'American Airlines',
        imageUrl: 'https://images.unsplash.com/photo-coffee',
        validFrom: pastMonth,
        validUntil: oneMonthAhead,
        termsAndConditions:
            'Tall size hot or iced drip coffee only. One per boarding pass. Valid day of travel.',
      ),

      // Delta
      Offer(
        id: 'offer-dl-001',
        title: 'Delta Sky Club: \$15 Day Pass',
        merchant: 'Delta Sky Club',
        description:
            'Exclusive reduced rate for Delta passengers. Access the Sky Club with premium buffet, cocktails, and shower suites.',
        discount: 'ONLY \$15',
        category: 'lounge',
        airportCode: 'JFK',
        airline: 'Delta',
        imageUrl: 'https://images.unsplash.com/photo-sky-club',
        validFrom: pastMonth,
        validUntil: twoMonthsAhead,
        termsAndConditions:
            'Delta boarding pass required. Subject to capacity. Terminal 4 only.',
      ),
      Offer(
        id: 'offer-dl-002',
        title: 'Delta Flyers: 30% Off Dining',
        merchant: 'Deep Blue Sushi',
        description:
            'Flying Delta? Get 30% off your entire bill at Deep Blue Sushi. Fresh sushi, sashimi, and sake.',
        discount: '30% OFF',
        category: 'dining',
        airportCode: 'JFK',
        airline: 'Delta',
        imageUrl: 'https://images.unsplash.com/photo-sushi',
        validFrom: pastMonth,
        validUntil: oneMonthAhead,
        termsAndConditions:
            'Show Delta boarding pass. Cannot be combined with other offers. Dine-in only.',
      ),
      Offer(
        id: 'offer-dl-003',
        title: 'Free Travel Kit for Delta Pax',
        merchant: 'Hudson News',
        description:
            'Delta passengers receive a complimentary travel comfort kit including eye mask, earplugs, and neck pillow with any \$20+ purchase.',
        discount: 'FREE KIT',
        category: 'shopping',
        airportCode: 'JFK',
        airline: 'Delta',
        imageUrl: 'https://images.unsplash.com/photo-travel-kit',
        validFrom: pastMonth,
        validUntil: oneMonthAhead,
        termsAndConditions:
            'Minimum \$20 purchase required. While supplies last. Delta boarding pass required.',
      ),

      // United
      Offer(
        id: 'offer-ua-001',
        title: 'United Club: Free Guest Pass',
        merchant: 'United Club',
        description:
            'United passengers can bring one guest free to the United Club lounge. Premium food, drinks, and workspace.',
        discount: 'FREE GUEST',
        category: 'lounge',
        airportCode: 'JFK',
        airline: 'United',
        imageUrl: 'https://images.unsplash.com/photo-united-club',
        validFrom: pastMonth,
        validUntil: twoMonthsAhead,
        termsAndConditions:
            'United boarding pass required for both member and guest. Day of travel only.',
      ),
      Offer(
        id: 'offer-ua-002',
        title: '20% Off Electronics for United',
        merchant: 'InMotion Entertainment',
        description:
            'United passengers save 20% on all headphones, chargers, and power banks at InMotion stores.',
        discount: '20% OFF',
        category: 'shopping',
        airportCode: 'JFK',
        airline: 'United',
        promoCode: 'UNITED20',
        imageUrl: 'https://images.unsplash.com/photo-electronics-store',
        validFrom: pastMonth,
        validUntil: oneMonthAhead,
        termsAndConditions:
            'Show United boarding pass. Excludes Apple products. One per passenger.',
      ),

      // British Airways
      Offer(
        id: 'offer-ba-001',
        title: 'BA Lounge: Champagne Upgrade',
        merchant: 'British Airways Lounge',
        description:
            'British Airways passengers get a complimentary champagne upgrade in the BA Galleries Lounge.',
        discount: 'FREE UPGRADE',
        category: 'lounge',
        airportCode: 'JFK',
        airline: 'British Airways',
        imageUrl: 'https://images.unsplash.com/photo-champagne',
        validFrom: pastMonth,
        validUntil: twoMonthsAhead,
        termsAndConditions:
            'BA boarding pass required. Business and First class passengers. Subject to availability.',
      ),
      Offer(
        id: 'offer-ba-002',
        title: 'BA Exclusive: Tax-Free Burberry',
        merchant: 'Burberry',
        description:
            'British Airways passengers enjoy additional 10% off tax-free Burberry purchases. Scarves, bags, and accessories.',
        discount: '10% EXTRA',
        category: 'duty_free',
        airportCode: 'JFK',
        airline: 'British Airways',
        imageUrl: 'https://images.unsplash.com/photo-burberry',
        validFrom: pastMonth,
        validUntil: oneMonthAhead,
        termsAndConditions:
            'BA boarding pass required. Cannot combine with other promotions. Minimum \$100 purchase.',
      ),

      // --- LAX Offers ---
      Offer(
        id: 'offer-006',
        title: 'Free Coffee with Any Meal',
        merchant: 'Starbucks',
        description:
            'Purchase any meal item and receive a complimentary tall drip coffee or tea at Starbucks LAX.',
        discount: 'FREE COFFEE',
        category: 'dining',
        airportCode: 'LAX',
        imageUrl: 'https://images.unsplash.com/photo-starbucks',
        validFrom: now.subtract(const Duration(days: 15)),
        validUntil: oneMonthAhead,
        termsAndConditions:
            'Valid at LAX Terminal 1 and Terminal 4 Starbucks locations. Tall size only. Hot or iced drip coffee/tea.',
      ),
      Offer(
        id: 'offer-007',
        title: 'Buy 2 Get 1 Free Souvenirs',
        merchant: 'LA Photo Shop',
        description:
            'Stock up on LA-themed souvenirs, magnets, and keychains. Buy any 2 and get the 3rd free.',
        discount: 'BUY 2 GET 1',
        category: 'shopping',
        airportCode: 'LAX',
        imageUrl: 'https://images.unsplash.com/photo-souvenirs',
        validFrom: pastMonth,
        validUntil: twoMonthsAhead,
        termsAndConditions:
            'Lowest priced item is free. Valid on souvenir items only. Not valid on electronics or books.',
      ),
      Offer(
        id: 'offer-008',
        title: 'Lounge Access from \$35',
        merchant: 'Star Alliance Lounge',
        description:
            'Experience premium comfort at the Star Alliance Lounge. Complimentary snacks, premium bar, and fast Wi-Fi.',
        discount: 'FROM \$35',
        category: 'lounge',
        airportCode: 'LAX',
        imageUrl: 'https://images.unsplash.com/photo-lounge-lax',
        validFrom: pastMonth,
        validUntil: twoMonthsAhead,
        termsAndConditions:
            'Walk-in availability not guaranteed. Maximum 3-hour stay. Smart casual dress code applies.',
      ),
      // LAX airline-specific
      Offer(
        id: 'offer-aa-lax-001',
        title: 'AA Flyers: Priority Dining',
        merchant: 'Real Food Daily',
        description:
            'American Airlines passengers skip the line and get 15% off at Real Food Daily. Organic, fresh, healthy.',
        discount: '15% OFF',
        category: 'dining',
        airportCode: 'LAX',
        airline: 'American Airlines',
        imageUrl: 'https://images.unsplash.com/photo-healthy-food',
        validFrom: pastMonth,
        validUntil: oneMonthAhead,
        termsAndConditions:
            'Show AA boarding pass. Valid for dine-in and takeaway. Cannot combine with other offers.',
      ),
      Offer(
        id: 'offer-ua-lax-001',
        title: 'United: Free Bag Tag & Travel Set',
        merchant: 'Tumi',
        description:
            'United passengers receive a complimentary Tumi bag tag and mini travel pouch with any purchase over \$100.',
        discount: 'FREE GIFT',
        category: 'shopping',
        airportCode: 'LAX',
        airline: 'United',
        imageUrl: 'https://images.unsplash.com/photo-luggage-tag',
        validFrom: pastMonth,
        validUntil: oneMonthAhead,
        termsAndConditions:
            'United boarding pass required. While supplies last. One per customer.',
      ),

      // --- LHR Offers ---
      Offer(
        id: 'offer-011',
        title: 'Buy 1 Get 1 Free at WHSmith',
        merchant: 'WHSmith',
        description:
            'Buy one book or magazine and get a second of equal or lesser value free at WHSmith Heathrow.',
        discount: 'BUY 1 GET 1',
        category: 'shopping',
        airportCode: 'LHR',
        imageUrl: 'https://images.unsplash.com/photo-bookstore',
        validFrom: pastMonth,
        validUntil: twoWeeksAhead,
        termsAndConditions:
            'Valid on books and magazines only. Lower-priced item is free. One redemption per customer.',
      ),
      Offer(
        id: 'offer-012',
        title: '30% Off Afternoon Tea',
        merchant: 'Fortnum & Mason',
        description:
            'Indulge in a traditional English afternoon tea with 30% off at Fortnum & Mason, Heathrow T5.',
        discount: '30% OFF',
        category: 'dining',
        airportCode: 'LHR',
        promoCode: 'TEA30LHR',
        imageUrl: 'https://images.unsplash.com/photo-afternoon-tea',
        validFrom: now.subtract(const Duration(days: 7)),
        validUntil: oneMonthAhead,
        termsAndConditions:
            'Valid at Terminal 5 location only. Advance booking recommended. Subject to availability.',
      ),
      Offer(
        id: 'offer-013',
        title: 'Tax-Free Luxury Watches',
        merchant: 'Harrods',
        description:
            'Shop tax-free on luxury watches from Rolex, Omega, TAG Heuer, and more at Harrods Heathrow.',
        discount: 'TAX FREE',
        category: 'duty_free',
        airportCode: 'LHR',
        imageUrl: 'https://images.unsplash.com/photo-luxury-watch',
        validFrom: pastMonth,
        validUntil: twoMonthsAhead,
        termsAndConditions:
            'Available to international departing passengers only. UK VAT savings of 20%. Subject to stock availability.',
      ),
      // LHR BA-specific
      Offer(
        id: 'offer-ba-lhr-001',
        title: 'BA Galleries First: Spa Access',
        merchant: 'Elemis Spa',
        description:
            'British Airways passengers get 50% off Elemis spa treatments in the BA Galleries First lounge at T5.',
        discount: '50% OFF SPA',
        category: 'lounge',
        airportCode: 'LHR',
        airline: 'British Airways',
        imageUrl: 'https://images.unsplash.com/photo-spa-treatment',
        validFrom: pastMonth,
        validUntil: twoMonthsAhead,
        termsAndConditions:
            'BA boarding pass required. First and Business class only. Advance booking recommended.',
      ),
      Offer(
        id: 'offer-ba-lhr-002',
        title: 'BA: Exclusive Harrods Hamper',
        merchant: 'Harrods',
        description:
            'British Airways passengers can pre-order an exclusive Harrods travel hamper with premium British treats, delivered to your seat.',
        discount: 'EXCLUSIVE',
        category: 'shopping',
        airportCode: 'LHR',
        airline: 'British Airways',
        imageUrl: 'https://images.unsplash.com/photo-hamper',
        validFrom: pastMonth,
        validUntil: oneMonthAhead,
        termsAndConditions:
            'Pre-order 24h before departure. BA long-haul flights only. Subject to availability.',
      ),

      // --- CDG Offers ---
      Offer(
        id: 'offer-024',
        title: '20% Off French Wine Selection',
        merchant: 'Buy Paris Duty Free',
        description:
            'Discover premium French wines with 20% off a curated selection of Bordeaux, Burgundy, and Champagne.',
        discount: '20% OFF',
        category: 'duty_free',
        airportCode: 'CDG',
        promoCode: 'WINE20CDG',
        imageUrl: 'https://images.unsplash.com/photo-french-wine',
        validFrom: pastMonth,
        validUntil: oneMonthAhead,
        termsAndConditions:
            'Valid on selected wines marked with promotion sticker. Maximum 6 bottles per customer. Departing passengers only.',
      ),
      Offer(
        id: 'offer-025',
        title: 'Croissant & Coffee Combo \u20AC5',
        merchant: 'Paul Bakery',
        description:
            'Enjoy a freshly baked butter croissant with an espresso or cafe creme for just \u20AC5 at Paul.',
        discount: 'ONLY \u20AC5',
        category: 'dining',
        airportCode: 'CDG',
        imageUrl: 'https://images.unsplash.com/photo-croissant',
        validFrom: now.subtract(const Duration(days: 5)),
        validUntil: threeDaysAhead,
        termsAndConditions:
            'Valid before 11:00 AM only. Terminal 2E and 2F locations. While supplies last.',
      ),
      // CDG Air France specific
      Offer(
        id: 'offer-af-001',
        title: 'Air France: Salon Premiere Access',
        merchant: 'Air France Lounge',
        description:
            'Air France passengers enjoy complimentary access to the Salon Premiere with gourmet French cuisine and fine wines.',
        discount: 'FREE ACCESS',
        category: 'lounge',
        airportCode: 'CDG',
        airline: 'Air France',
        imageUrl: 'https://images.unsplash.com/photo-french-lounge',
        validFrom: pastMonth,
        validUntil: twoMonthsAhead,
        termsAndConditions:
            'Air France boarding pass required. Business and La Premiere class. Terminal 2E.',
      ),
      Offer(
        id: 'offer-af-002',
        title: 'AF Flyers: 40% Off Laduree',
        merchant: 'Laduree',
        description:
            'Air France passengers get 40% off Laduree macaron gift boxes. The perfect Parisian souvenir.',
        discount: '40% OFF',
        category: 'shopping',
        airportCode: 'CDG',
        airline: 'Air France',
        imageUrl: 'https://images.unsplash.com/photo-macarons',
        validFrom: pastMonth,
        validUntil: oneMonthAhead,
        termsAndConditions:
            'Air France boarding pass required. Valid on gift boxes only. One per passenger.',
      ),

      // --- DXB Offers ---
      Offer(
        id: 'offer-016',
        title: '15% Off Luxury Brands',
        merchant: 'Dubai Duty Free',
        description:
            'Save 15% on luxury fashion, accessories, and cosmetics from top brands at Dubai Duty Free.',
        discount: '15% OFF',
        category: 'duty_free',
        airportCode: 'DXB',
        promoCode: 'LUXDXB15',
        imageUrl: 'https://images.unsplash.com/photo-luxury-shopping',
        validFrom: pastMonth,
        validUntil: twoMonthsAhead,
        termsAndConditions:
            'Valid on purchases over AED 500. Excludes gold and electronics. One per passport per visit.',
      ),
      Offer(
        id: 'offer-019',
        title: 'Complimentary Dates & Arabic Coffee',
        merchant: 'Bateel Cafe',
        description:
            'Enjoy complimentary premium dates and Arabic coffee with any food order at Bateel Cafe.',
        discount: 'FREE TREAT',
        category: 'dining',
        airportCode: 'DXB',
        imageUrl: 'https://images.unsplash.com/photo-arabic-coffee',
        validFrom: pastMonth,
        validUntil: twoMonthsAhead,
        termsAndConditions:
            'Valid with minimum food purchase of AED 50. One per table per visit.',
      ),
      // DXB Emirates specific
      Offer(
        id: 'offer-ek-001',
        title: 'Emirates: Free Chauffeur Service',
        merchant: 'Emirates',
        description:
            'Emirates Business & First class passengers enjoy complimentary chauffeur-driven airport transfer in luxury vehicles.',
        discount: 'FREE TRANSFER',
        category: 'travel',
        airportCode: 'DXB',
        airline: 'Emirates',
        imageUrl: 'https://images.unsplash.com/photo-luxury-transfer',
        validFrom: pastMonth,
        validUntil: twoMonthsAhead,
        termsAndConditions:
            'Business and First class tickets only. Book 48h in advance. Within Dubai city limits.',
      ),
      Offer(
        id: 'offer-ek-002',
        title: 'Emirates: 35% Off Dubai Duty Free',
        merchant: 'Dubai Duty Free',
        description:
            'Emirates passengers save 35% on perfumes, cosmetics, and premium chocolates at Dubai Duty Free.',
        discount: '35% OFF',
        category: 'duty_free',
        airportCode: 'DXB',
        airline: 'Emirates',
        promoCode: 'EKFLY35',
        imageUrl: 'https://images.unsplash.com/photo-dubai-dutyfree',
        validFrom: pastMonth,
        validUntil: oneMonthAhead,
        termsAndConditions:
            'Emirates boarding pass required. Minimum AED 200 purchase. One per passenger.',
      ),

      // --- SIN Offers ---
      Offer(
        id: 'offer-021',
        title: '\$5 Off Jewel Changi Dining',
        merchant: 'Jewel Changi Airport',
        description:
            'Get \$5 off when you spend \$30 or more at any participating restaurant in Jewel Changi Airport.',
        discount: '\$5 OFF',
        category: 'dining',
        airportCode: 'SIN',
        promoCode: 'JEWELDINE5',
        imageUrl: 'https://images.unsplash.com/photo-changi-dining',
        validFrom: pastMonth,
        validUntil: oneMonthAhead,
        termsAndConditions:
            'Valid at participating outlets in Jewel only. Single receipt. Not valid with other promotions.',
      ),
      Offer(
        id: 'offer-023',
        title: '10% Off Electronics',
        merchant: 'Changi Duty Free',
        description:
            'Save 10% on electronics including cameras, tablets, and portable speakers at Changi Duty Free.',
        discount: '10% OFF',
        category: 'duty_free',
        airportCode: 'SIN',
        promoCode: 'TECH10SIN',
        imageUrl: 'https://images.unsplash.com/photo-electronics',
        validFrom: now.subtract(const Duration(days: 8)),
        validUntil: twoWeeksAhead,
        termsAndConditions:
            'Excludes Apple products and pre-order items. Cannot be combined with member discounts.',
      ),
      // SIN Singapore Airlines specific
      Offer(
        id: 'offer-sq-001',
        title: 'SQ: Silver Kris Lounge + Spa',
        merchant: 'Singapore Airlines',
        description:
            'Singapore Airlines passengers get complimentary Silver Kris Lounge access with a free 15-min spa treatment.',
        discount: 'FREE SPA',
        category: 'lounge',
        airportCode: 'SIN',
        airline: 'Singapore Airlines',
        imageUrl: 'https://images.unsplash.com/photo-kris-lounge',
        validFrom: pastMonth,
        validUntil: twoMonthsAhead,
        termsAndConditions:
            'SQ boarding pass required. Business and First class. Terminal 3. Advance spa booking required.',
      ),
      Offer(
        id: 'offer-sq-002',
        title: 'SQ Flyers: 20% Off Changi Shop',
        merchant: 'iShopChangi',
        description:
            'Singapore Airlines passengers enjoy 20% off all purchases at iShopChangi. Electronics, fashion, and beauty.',
        discount: '20% OFF',
        category: 'shopping',
        airportCode: 'SIN',
        airline: 'Singapore Airlines',
        promoCode: 'SQSHOP20',
        imageUrl: 'https://images.unsplash.com/photo-changi-shop',
        validFrom: pastMonth,
        validUntil: oneMonthAhead,
        termsAndConditions:
            'SQ boarding pass required. Valid in-store and on iShopChangi app. One per passenger.',
      ),

      // --- NRT Offers ---
      Offer(
        id: 'offer-027',
        title: 'Ramen & Beer Set \u00A51200',
        merchant: 'Narita Ramen Street',
        description:
            'Savor authentic Japanese ramen with a draft beer for a special airport price at Narita Ramen Street.',
        discount: 'SET \u00A51200',
        category: 'dining',
        airportCode: 'NRT',
        imageUrl: 'https://images.unsplash.com/photo-ramen',
        validFrom: pastMonth,
        validUntil: oneMonthAhead,
        termsAndConditions:
            'Available at all Ramen Street restaurants in Terminal 1. Lunch hours (11:00-14:00) only.',
      ),
      Offer(
        id: 'offer-028',
        title: 'Tax-Free Japanese Whisky',
        merchant: 'Fa-So-La Duty Free',
        description:
            'Premium Japanese whisky collection including Yamazaki, Hakushu, and Hibiki at duty-free prices.',
        discount: 'TAX FREE',
        category: 'duty_free',
        airportCode: 'NRT',
        imageUrl: 'https://images.unsplash.com/photo-japanese-whisky',
        validFrom: pastMonth,
        validUntil: twoMonthsAhead,
        termsAndConditions:
            'Subject to stock availability. Limit 2 bottles per passenger. International departures only.',
      ),
      // NRT Japan Airlines specific
      Offer(
        id: 'offer-jl-001',
        title: 'JAL: Sakura Lounge Premium',
        merchant: 'Japan Airlines',
        description:
            'Japan Airlines passengers enjoy the Sakura Lounge with complimentary sushi bar, sake selection, and shower rooms.',
        discount: 'FREE ACCESS',
        category: 'lounge',
        airportCode: 'NRT',
        airline: 'Japan Airlines',
        imageUrl: 'https://images.unsplash.com/photo-sakura-lounge',
        validFrom: pastMonth,
        validUntil: twoMonthsAhead,
        termsAndConditions:
            'JAL boarding pass required. Business and First class. Terminal 1 satellite.',
      ),
      Offer(
        id: 'offer-jl-002',
        title: 'JAL: 30% Off Japanese Souvenirs',
        merchant: 'Fa-So-La Tax Free',
        description:
            'Japan Airlines passengers save 30% on traditional Japanese souvenirs - matcha sets, ceramics, and wagashi sweets.',
        discount: '30% OFF',
        category: 'shopping',
        airportCode: 'NRT',
        airline: 'Japan Airlines',
        imageUrl: 'https://images.unsplash.com/photo-japanese-souvenirs',
        validFrom: pastMonth,
        validUntil: oneMonthAhead,
        termsAndConditions:
            'JAL boarding pass required. One per passenger. Cannot combine with tax-free discount.',
      ),

      // --- SFO Offers ---
      Offer(
        id: 'offer-029',
        title: 'Napa Valley Wine Tasting Free',
        merchant: 'Vino Volo',
        description:
            'Complimentary wine tasting flight featuring three Napa Valley wines at Vino Volo, SFO Terminal 2.',
        discount: 'FREE TASTING',
        category: 'dining',
        airportCode: 'SFO',
        imageUrl: 'https://images.unsplash.com/photo-wine-tasting',
        validFrom: now.subtract(const Duration(days: 12)),
        validUntil: twoWeeksAhead,
        termsAndConditions:
            'One complimentary tasting per customer. Must be 21+. Terminal 2 post-security location only.',
      ),
      Offer(
        id: 'offer-030',
        title: 'SFO Lounge Pass \$39',
        merchant: 'The Club SFO',
        description:
            'All-inclusive lounge access with premium food, cocktails, and fast Wi-Fi at The Club, SFO.',
        discount: 'ONLY \$39',
        category: 'lounge',
        airportCode: 'SFO',
        imageUrl: 'https://images.unsplash.com/photo-lounge-sfo',
        validFrom: pastMonth,
        validUntil: twoMonthsAhead,
        termsAndConditions:
            'Walk-in subject to capacity. Maximum 3-hour stay. Children 2-12 at half price.',
      ),
      // SFO United specific
      Offer(
        id: 'offer-ua-sfo-001',
        title: 'United Polaris Lounge Access',
        merchant: 'United Airlines',
        description:
            'United passengers enjoy the award-winning Polaris Lounge with chef-curated dining, cocktail bar, and daybeds.',
        discount: 'FREE ACCESS',
        category: 'lounge',
        airportCode: 'SFO',
        airline: 'United',
        imageUrl: 'https://images.unsplash.com/photo-polaris-lounge',
        validFrom: pastMonth,
        validUntil: twoMonthsAhead,
        termsAndConditions:
            'United international Business or First class boarding pass required. International Terminal.',
      ),
    ];
  }
}
