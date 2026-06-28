import 'package:flutter/material.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/features/airport/domain/entities/airport.dart';

class AirportCard extends StatelessWidget {
  final Airport airport;
  final VoidCallback onTap;

  const AirportCard({
    super.key,
    required this.airport,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image placeholder with gradient and icon
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _gradientColors(airport.iataCode),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.flight,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        airport.iataCode,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Info section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      airport.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${airport.city}, ${airport.country}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _gradientColors(String code) {
    switch (code) {
      case 'JFK':
        return [const Color(0xFF1565C0), const Color(0xFF0D47A1)];
      case 'LAX':
        return [const Color(0xFFE65100), const Color(0xFFBF360C)];
      case 'LHR':
        return [const Color(0xFF283593), const Color(0xFF1A237E)];
      case 'CDG':
        return [const Color(0xFF00695C), const Color(0xFF004D40)];
      case 'DXB':
        return [const Color(0xFFAD1457), const Color(0xFF880E4F)];
      case 'SIN':
        return [const Color(0xFF4A148C), const Color(0xFF311B92)];
      case 'NRT':
        return [const Color(0xFFC62828), const Color(0xFFB71C1C)];
      case 'SFO':
        return [const Color(0xFF00838F), const Color(0xFF006064)];
      default:
        return [AppColors.primary, AppColors.primaryDark];
    }
  }
}
