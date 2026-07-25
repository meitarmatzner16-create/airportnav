import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../features/venues/domain/entities/venue.dart';

/// Deterministic, on-brand image tile for a venue. Renders a category-tinted
/// gradient + a translucent category glyph + soft motif circles seeded by the
/// venue id, so every venue looks distinct and identical across rebuilds.
///
/// If `venue.photo.asset`/`url` is set, a real image is shown instead (future).
class VenueImage extends StatelessWidget {
  final Venue venue;
  final double? height;
  final double? size;
  final BorderRadius? radius;

  const VenueImage({
    super.key,
    required this.venue,
    this.height,
    this.size,
    this.radius,
  });

  /// Stable per-venue seed (content-based; identical across rebuilds).
  static int seedOf(Venue v) => (v.photo?.seed ?? v.id).hashCode.abs();

  /// Two-tone gradient tint per category, cohesive with the sky palette.
  static List<Color> gradientFor(Venue v) {
    const palettes = <String, List<Color>>{
      'dining': [Color(0xFFEAF1FF), Color(0xFFD6E4FF)],
      'lounge': [Color(0xFFEAF0FF), Color(0xFFDDE7FF)],
      'duty_free': [Color(0xFFEFEBFF), Color(0xFFE1DAFF)],
      'luxury': [Color(0xFFF1ECFF), Color(0xFFE6DBFF)],
      'electronics': [Color(0xFFE7F3FF), Color(0xFFD3EAFF)],
      'convenience': [Color(0xFFEAF3EF), Color(0xFFD9EBE3)],
      'retail': [Color(0xFFEDF0F6), Color(0xFFDCE3F0)],
    };
    return palettes[v.category] ?? const [Color(0xFFEDF0F6), Color(0xFFDCE3F0)];
  }

  static IconData _glyph(Venue v) => switch (v.category) {
        'dining' => Icons.restaurant_rounded,
        'lounge' => Icons.weekend_rounded,
        'duty_free' => Icons.redeem_rounded,
        'luxury' => Icons.diamond_rounded,
        'electronics' => Icons.devices_rounded,
        'convenience' => Icons.local_convenience_store_rounded,
        _ => Icons.storefront_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final r = radius ?? BorderRadius.circular(16);
    final seed = seedOf(venue);
    final g = gradientFor(venue);
    // Deterministic motif offsets from the seed.
    final dx = (seed % 7) / 7.0; // 0..1
    final dy = ((seed ~/ 7) % 5) / 5.0; // 0..1
    final h = size ?? height;

    return ClipRRect(
      borderRadius: r,
      child: SizedBox(
        width: size,
        height: h,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1 + dx, -1),
                  end: Alignment(1, 1 - dy),
                  colors: g,
                ),
              ),
            ),
            Positioned(
              right: -14 - dx * 8,
              top: -10 + dy * 14,
              child: _softCircle(48 + (seed % 20).toDouble()),
            ),
            Positioned(
              left: -8 + dx * 10,
              bottom: -12,
              child: _softCircle(30 + (seed % 14).toDouble()),
            ),
            Center(
              child: Icon(
                _glyph(venue),
                color: AppColors.sky.withValues(alpha: 0.28),
                size: (h ?? 64) * 0.42,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _softCircle(double d) => Container(
        width: d,
        height: d,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.35),
        ),
      );
}
