import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A 1px hairline divider with a short centered gold accent gradient.
///
/// The base line uses `hairline` (light) / `dHairline` (dark).
/// The 80px center accent fades transparent → goldAlpha15 → gold → goldAlpha15 → transparent.
class GoldDivider extends StatelessWidget {
  const GoldDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark ? AppColors.dHairline : AppColors.hairline;

    return SizedBox(
      height: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Full-width hairline
          Container(color: lineColor),
          // Centered 80px gold accent
          Container(
            width: 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.goldAlpha15,
                  AppColors.gold,
                  AppColors.goldAlpha15,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
