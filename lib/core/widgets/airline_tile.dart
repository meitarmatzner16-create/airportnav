import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// Two-letter IATA code parsed from a flight number like "AA 2468" → "AA".
String airlineCodeOf(String flightNumber) {
  final trimmed = flightNumber.trim();
  final space = trimmed.indexOf(' ');
  final code = space > 0 ? trimmed.substring(0, space) : trimmed;
  return code.toUpperCase();
}

/// Brand color for an airline code, kept within a calm blue family so the
/// board stays cohesive with the friendly-blue accent. Falls back to sky.
///
/// These are simple solid brand tints - we deliberately do **not** reproduce
/// any airline's actual logo artwork.
Color airlineColor(String code) {
  switch (code) {
    case 'DL':
      return const Color(0xFF1B2A63); // Delta
    case 'B6':
      return const Color(0xFF0A44C2); // JetBlue
    case 'AA':
      return const Color(0xFF1B75BB); // American
    case 'UA':
      return const Color(0xFF0A5EB0); // United
    case 'WN':
      return const Color(0xFF2E4CA6); // Southwest
    case 'BA':
      return const Color(0xFF1D4E9B);
    case 'AF':
      return const Color(0xFF16357A);
    case 'SQ':
      return const Color(0xFF12386E);
    case 'EK':
      return const Color(0xFF184E86);
    case 'JL':
      return const Color(0xFF1A3E7A);
    default:
      return AppColors.sky;
  }
}

/// Circular airline mark: a brand-colored disc showing the IATA code, or a
/// filled check when [selected] (used to mark the chosen departures row).
class AirlineTile extends StatelessWidget {
  final String flightNumber;
  final double size;
  final bool selected;

  const AirlineTile({
    super.key,
    required this.flightNumber,
    this.size = 40,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.sky,
        ),
        child: Icon(Icons.check_rounded, color: Colors.white, size: size * 0.52),
      );
    }

    final code = airlineCodeOf(flightNumber);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: airlineColor(code),
      ),
      child: Text(
        code,
        textAlign: TextAlign.center,
        style: AppTypography.mono(
          fontSize: size * 0.3,
          weight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
