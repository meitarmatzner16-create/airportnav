import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Sky→sky2 gradient container with a 3px gold hairline across the top.
///
/// `colors` defaults to [AppColors.sky, AppColors.sky2].
/// NO perforation — that belongs to BoardingPassCard exclusively.
class GradientHero extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final double height;

  const GradientHero({
    super.key,
    required this.child,
    this.colors,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = colors ?? [AppColors.sky, AppColors.sky2];

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // Gradient body
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
              ),
              child: child,
            ),
          ),
          // 3px gold top hairline (gradient: gold → goldSoft → gold)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.gold, AppColors.goldSoft, AppColors.gold],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
