import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Star rating row.
///
/// Default color is `AppColors.gold` (Sky Pass palette).
/// Pass a custom `color` to override.
class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? AppColors.gold;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, size: size, color: starColor);
        } else if (index < rating) {
          return Icon(Icons.star_half, size: size, color: starColor);
        } else {
          return Icon(Icons.star_border, size: size, color: starColor);
        }
      }),
    );
  }
}
