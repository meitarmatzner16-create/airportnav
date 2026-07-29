import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/branding/app_logo.dart';
import '../../../core/constants/app_colors.dart';
import '../data/onboarding_prefs.dart';

/// Brand moment: the pass lands, the route runs across it, the plane lifts off
/// the end of that route, and the wordmark rises.
///
/// Driven by ONE forward controller with a status listener - deliberately no
/// `repeat()` and no `Future.delayed`, both of which leaked timers and broke
/// the app smoke test.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _tile;
  late final Animation<double> _route;
  late final Animation<double> _plane;
  late final Animation<double> _word;

  static const _kLogoSize = 116.0;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    Animation<double> beat(double begin, double end, Curve curve) =>
        CurvedAnimation(parent: _c, curve: Interval(begin, end, curve: curve));

    _tile = beat(0.00, 0.21, Curves.easeOutCubic); // 0-350ms
    _route = beat(0.18, 0.53, Curves.easeOut); // 300-900ms
    _plane = beat(0.41, 0.68, Curves.easeOutCubic); // 700-1150ms
    _word = beat(0.59, 0.88, Curves.easeOut); // 1000-1500ms

    _c.addStatusListener(_onDone);
    _c.forward();
  }

  Future<void> _onDone(AnimationStatus status) async {
    if (status != AnimationStatus.completed) return;
    final seen = await OnboardingPrefs.seen();
    if (!mounted) return;
    context.go(seen ? '/home' : '/onboarding');
  }

  @override
  void dispose() {
    _c.removeStatusListener(_onDone);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Center(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Soft sky glow behind the mark.
                Container(
                  width: _kLogoSize * 2.1,
                  height: _kLogoSize * 2.1,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.skyTint.withValues(alpha: 0.85 * _tile.value),
                      AppColors.paper.withValues(alpha: 0),
                    ]),
                  ),
                  child: Transform.scale(
                    scale: 0.86 + (0.14 * _tile.value),
                    child: AppLogo(
                      size: _kLogoSize,
                      tileProgress: _tile.value,
                      routeProgress: _route.value,
                      planeProgress: _plane.value,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Transform.translate(
                  offset: Offset(0, 8 * (1 - _word.value)),
                  child: Opacity(
                    opacity: _word.value,
                    child: Text(
                      'AirportNav',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
