import 'package:flutter/material.dart';
import 'logo_painter.dart';

export 'logo_painter.dart' show AppLogoVariant;

/// The AirportNav mark - a notched boarding-pass tile whose interior becomes a
/// route and takes flight.
///
/// Below 24px the route dots are omitted automatically (they turn to mud at
/// that scale) and the plane carries the mark.
class AppLogo extends StatelessWidget {
  final double size;
  final AppLogoVariant variant;
  final bool? showRoute;
  final double tileProgress;
  final double routeProgress;
  final double planeProgress;

  const AppLogo({
    super.key,
    required this.size,
    this.variant = AppLogoVariant.sky,
    this.showRoute,
    this.tileProgress = 1,
    this.routeProgress = 1,
    this.planeProgress = 1,
  });

  /// Whether the route dots will be painted at this size / override.
  bool get routeVisible => showRoute ?? (size >= 24);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: LogoPainter(
          variant: variant,
          showRoute: routeVisible,
          tileProgress: tileProgress,
          routeProgress: routeProgress,
          planeProgress: planeProgress,
        ),
      ),
    );
  }
}

/// Mark + "AirportNav" wordmark.
class AppLogoLockup extends StatelessWidget {
  final double size;
  final AppLogoVariant variant;
  final double wordmarkOpacity;
  final double wordmarkOffsetY;

  const AppLogoLockup({
    super.key,
    this.size = 30,
    this.variant = AppLogoVariant.sky,
    this.wordmarkOpacity = 1,
    this.wordmarkOffsetY = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogo(size: size, variant: variant),
        SizedBox(width: size * 0.28),
        Transform.translate(
          offset: Offset(0, wordmarkOffsetY),
          child: Opacity(
            opacity: wordmarkOpacity.clamp(0, 1),
            child: Text(
              'AirportNav',
              style: theme.textTheme.displaySmall?.copyWith(
                fontSize: size * 0.72,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
