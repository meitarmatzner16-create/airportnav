import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:airport_nav/features/venues/domain/entities/venue_details.dart';

void main() {
  test('AmenityInfo.of is total and labels use hyphen-minus only', () {
    for (final a in Amenity.values) {
      final info = AmenityInfo.of(a);
      expect(info.label, isNotEmpty);
      expect(info.label.contains('–'), isFalse); // en dash
      expect(info.label.contains('—'), isFalse); // em dash
      expect(info.icon, isA<IconData>());
    }
  });

  test('PriceLevel symbols render \$..\$\$\$\$', () {
    expect(PriceLevel.one.symbols, r'$');
    expect(PriceLevel.two.symbols, r'$$');
    expect(PriceLevel.three.symbols, r'$$$');
    expect(PriceLevel.four.symbols, r'$$$$');
  });
}
