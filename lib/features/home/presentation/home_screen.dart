import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boarding_pass_card.dart';
import '../../../core/widgets/nearby_card.dart';
import '../../../features/flight/domain/entities/flight.dart';
import '../../../features/flight/presentation/providers/flight_providers.dart';
import '../../../features/venues/presentation/providers/venue_providers.dart';
import '../../../features/voice_chat/presentation/providers/voice_chat_providers.dart';

/// Screen horizontal gutter per design spec (24px, overrides old 20px).
const _gutter = 24.0;

/// Section vertical gap.
const _sectionGap = 28.0;

/// Wider gap before Near-your-gate and Recent plans.
const _sectionGapLg = 32.0;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _airports = ['JFK', 'LAX', 'LHR', 'CDG', 'DXB', 'SIN', 'NRT', 'SFO'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final detectedAirport = ref.watch(detectedAirportProvider);
    final selectedFlight = ref.watch(selectedFlightProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      body: SafeArea(
        child: selectedFlight != null
            ? _DashboardView(
                flight: selectedFlight,
                detectedAirport: detectedAirport,
                isDark: isDark,
                onChangeFlight: () =>
                    ref.read(selectedFlightProvider.notifier).state = null,
                onChangeAirport: (v) {
                  ref.read(detectedAirportProvider.notifier).state = v;
                  ref.read(selectedFlightProvider.notifier).state = null;
                },
              )
            : _FlightPickerView(
                detectedAirport: detectedAirport,
                isDark: isDark,
                onChangeAirport: (v) {
                  ref.read(detectedAirportProvider.notifier).state = v;
                  ref.read(selectedFlightProvider.notifier).state = null;
                },
                onSelectFlight: (f) =>
                    ref.read(selectedFlightProvider.notifier).state = f,
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard (flight selected)
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardView extends ConsumerWidget {
  final Flight flight;
  final String detectedAirport;
  final bool isDark;
  final VoidCallback onChangeFlight;
  final ValueChanged<String> onChangeAirport;

  const _DashboardView({
    required this.flight,
    required this.detectedAirport,
    required this.isDark,
    required this.onChangeFlight,
    required this.onChangeAirport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final availableMinutes = ref.watch(availableTimeMinutesProvider) ?? 0;
    final venues = ref.watch(allVenuesProvider);
    final nearbyVenues = venues.take(5).toList();

    // Voice chat: check for real route plan (active plan) and history
    final currentPlan = ref.watch(currentItineraryProvider);
    final chatMessages = ref.watch(voiceChatMessagesProvider);
    // Only show Recent plans if user has exchanged messages (beyond the greeting)
    final hasHistory = chatMessages.length > 1;

    final boardingHours = availableMinutes ~/ 60;
    final boardingMins = availableMinutes % 60;
    final boardingLabel = boardingHours > 0
        ? '${boardingHours}h ${boardingMins}m until boarding'
        : '${boardingMins}m until boarding';

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ── Top bar ──────────────────────────────────────────────────
        _TopBar(
          detectedAirport: detectedAirport,
          airports: HomeScreen._airports,
          onChangeAirport: onChangeAirport,
        ),

        // ── Greeting + title block ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(_gutter, 8, _gutter, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _timeGreeting(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                flight.arrivalCity,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  color: isDark ? AppColors.dText : AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    '${DateFormat('d MMM yyyy').format(flight.departureTime)} · ${flight.flightNumber}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onChangeFlight,
                    behavior: HitTestBehavior.opaque,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Change',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.dSky : AppColors.sky,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Boarding pass card ────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _gutter),
          child: BoardingPassCard(
            flight: flight,
            onTap: () => context.push('/home/flight/${flight.id}'),
          ),
        ),

        const SizedBox(height: _sectionGap),

        // ── Voice CTA card ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _gutter),
          child: _VoiceCtaCard(isDark: isDark),
        ),

        const SizedBox(height: _sectionGap),

        // ── Quick add chips ───────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick add',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.dText : AppColors.ink,
                ),
              ),
              Text(
                boardingLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _QuickAddChips(isDark: isDark),

        // ── Active route (conditional) ────────────────────────────────
        if (currentPlan != null) ...[
          const SizedBox(height: _sectionGap),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _gutter),
            child: _ActiveRouteCard(plan: currentPlan, isDark: isDark),
          ),
        ],

        // ── Near your gate ────────────────────────────────────────────
        const SizedBox(height: _sectionGapLg),
        Padding(
          padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Near your gate',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.dText : AppColors.ink,
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/venues'),
                behavior: HitTestBehavior.opaque,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
                  child: Align(
                    child: Text(
                      'See all',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.dSky : AppColors.sky,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (nearbyVenues.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _gutter),
            child: Text(
              'No venues found nearby.',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          )
        else
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              itemCount: nearbyVenues.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final v = nearbyVenues[i];
                return NearbyCard(
                  venue: v,
                  walkMinutes: 2 + i,
                  onTap: () => context.go('/venues'),
                );
              },
            ),
          ),

        // ── Recent plans (conditional — only if real chat history) ────
        if (hasHistory) ...[
          const SizedBox(height: _sectionGapLg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _gutter),
            child: Text(
              'Recent plans',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.dText : AppColors.ink,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _RecentPlansSection(isDark: isDark),
        ],

        const SizedBox(height: _sectionGapLg),
      ],
    );
  }

  static String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar (logo + bell + airport selector)
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String detectedAirport;
  final List<String> airports;
  final ValueChanged<String> onChangeAirport;

  const _TopBar({
    required this.detectedAirport,
    required this.airports,
    required this.onChangeAirport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(_gutter, 12, _gutter, 4),
      child: Row(
        children: [
          // Logo
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.sky, AppColors.ink],
              ),
            ),
            child: const Icon(Icons.flight_rounded, size: 16, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.smMd),
          Text(
            'AirportNav',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: isDark ? AppColors.dSky : AppColors.sky,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const Spacer(),
          // Airport selector chip
          _AirportChip(
            value: detectedAirport,
            airports: airports,
            onChanged: onChangeAirport,
          ),
          const SizedBox(width: 8),
          // Bell icon ≥44px touch target
          Semantics(
            label: 'Notifications',
            button: true,
            child: GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 24,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Airport chip
// ─────────────────────────────────────────────────────────────────────────────

class _AirportChip extends StatelessWidget {
  final String value;
  final List<String> airports;
  final ValueChanged<String> onChanged;

  const _AirportChip({
    required this.value,
    required this.airports,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smMd, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.skyAlpha15 : AppColors.skyAlpha10,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
            color: isDark ? AppColors.skyAlpha20 : AppColors.skyAlpha15,
            width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.gps_fixed_rounded,
              size: 12,
              color: isDark ? AppColors.dSky : AppColors.sky),
          const SizedBox(width: 5),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              icon: Icon(Icons.arrow_drop_down_rounded,
                  size: 16,
                  color: isDark ? AppColors.dSky : AppColors.sky),
              style: theme.textTheme.labelLarge?.copyWith(
                color: isDark ? AppColors.dSky : AppColors.sky,
                fontWeight: FontWeight.w700,
              ),
              dropdownColor: isDark ? AppColors.dSurface : AppColors.card,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              items: [
                for (final a in airports)
                  DropdownMenuItem(value: a, child: Text(a)),
              ],
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Voice CTA card (navy ink background)
// ─────────────────────────────────────────────────────────────────────────────

class _VoiceCtaCard extends StatelessWidget {
  final bool isDark;
  const _VoiceCtaCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Always navy bg (ink) as per spec — same in dark mode (even darker surface)
    final bg = isDark ? const Color(0xFF081A3D) : AppColors.ink;

    return GestureDetector(
      onTap: () => context.go('/voice-chat'),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: AppShadows.lifted,
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Decorative concentric circles (top-right, opacity .12)
            Positioned(
              top: -30,
              right: -30,
              child: _ConcentricCircles(color: Colors.white.withAlpha(31)),
            ),
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label row
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 16, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      'PLAN WITH VOICE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Headline
                Text(
                  "Tell us what you want.\nWe'll build the route.",
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                // Sub text
                Text(
                  '"Coffee, perfume, and a 10-min massage" — timed perfectly with your gate.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: Colors.white.withAlpha(191), // .75
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                // Mic row
                Row(
                  children: [
                    // Mic circle
                    Semantics(
                      label: 'Hold to record voice',
                      button: true,
                      child: GestureDetector(
                        onTap: () => context.go('/voice-chat'),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(
                            Icons.mic_none_rounded,
                            size: 22,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Labels
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hold to record',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/voice-chat'),
                          child: Text(
                            'or type your wishlist →',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white60,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConcentricCircles extends StatelessWidget {
  final Color color;
  const _ConcentricCircles({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: CustomPaint(
        painter: _ConcentricCirclesPainter(color: color),
      ),
    );
  }
}

class _ConcentricCirclesPainter extends CustomPainter {
  final Color color;
  const _ConcentricCirclesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final center = Offset(size.width / 2, size.height / 2);
    for (final r in [30.0, 55.0, 80.0]) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(_ConcentricCirclesPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick-add chips
// ─────────────────────────────────────────────────────────────────────────────

class _QuickAddChips extends StatelessWidget {
  final bool isDark;
  const _QuickAddChips({required this.isDark});

  static const _chips = [
    (Icons.local_cafe_rounded, 'Coffee'),
    (Icons.shopping_bag_rounded, 'Shopping'),
    (Icons.weekend_rounded, 'Lounge'),
    (Icons.spa_rounded, 'Spa'),
    (Icons.restaurant_rounded, 'Food'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = isDark ? AppColors.dSurface : AppColors.card;
    final hairline = isDark ? AppColors.dHairline : AppColors.hairline;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: _gutter),
        itemCount: _chips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (icon, label) = _chips[i];
          return GestureDetector(
            onTap: () => context.go('/voice-chat'),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(color: hairline, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon,
                      size: 15,
                      color: isDark ? AppColors.dSky : AppColors.sky),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.dText : AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Active route preview card (conditional)
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveRouteCard extends StatelessWidget {
  final dynamic plan; // RoutePlan
  final bool isDark;

  const _ActiveRouteCard({required this.plan, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = isDark ? AppColors.dSurface : AppColors.card;
    final hairline = isDark ? AppColors.dHairline : AppColors.hairline;
    final iconBg = isDark ? AppColors.dSurfaceVariant : AppColors.skyTint;

    final totalMin = plan.totalMinutes as int;
    final stopsCount = (plan.stops as List).length;
    final hours = totalMin ~/ 60;
    final mins = totalMin % 60;
    final durationLabel = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    return GestureDetector(
      onTap: () => context.go('/map'),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: hairline, width: 1),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
              child: Row(
                children: [
                  // Route icon with ok dot
                  Stack(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: const Icon(Icons.route_rounded,
                            size: 22, color: AppColors.sky),
                      ),
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACTIVE PLAN',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 11,
                            color: AppColors.muted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          plan.summary as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.dText : AppColors.ink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$stopsCount stop${stopsCount == 1 ? '' : 's'} · $durationLabel',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      size: 22,
                      color: isDark ? AppColors.dMuted : const Color(0xFF9AA1B0)),
                ],
              ),
            ),
            // Progress bar (h4)
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.dSurfaceVariant : const Color(0xFFEEF1F4),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppSpacing.radiusLg),
                  bottomRight: Radius.circular(AppSpacing.radiusLg),
                ),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.28,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.dSky : AppColors.sky,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(AppSpacing.radiusLg),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent plans (conditional — only shown when real history exists)
// ─────────────────────────────────────────────────────────────────────────────

class _RecentPlansSection extends ConsumerWidget {
  final bool isDark;
  const _RecentPlansSection({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(voiceChatMessagesProvider);
    // Collect only bot messages with a route plan (real plans, not fabricated)
    final planMessages = messages
        .where((m) => !m.isUser && m.routePlan != null)
        .take(3)
        .toList();

    if (planMessages.isEmpty) return const SizedBox.shrink();

    final cardBg = isDark ? AppColors.dSurface : AppColors.card;
    final hairline = isDark ? AppColors.dHairline : AppColors.hairline;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _gutter),
      child: Column(
        children: [
          for (int i = 0; i < planMessages.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _HistoryRow(
              message: planMessages[i],
              isDark: isDark,
              cardBg: cardBg,
              hairline: hairline,
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final dynamic message;
  final bool isDark;
  final Color cardBg;
  final Color hairline;

  const _HistoryRow({
    required this.message,
    required this.isDark,
    required this.cardBg,
    required this.hairline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ts = message.timestamp as DateTime;
    final now = DateTime.now();
    final diff = now.difference(ts);
    final whenLabel = diff.inMinutes < 2
        ? 'Just now'
        : diff.inHours < 1
            ? '${diff.inMinutes}m ago'
            : diff.inHours < 24
                ? '${diff.inHours}h ago'
                : DateFormat('MMM d').format(ts);

    final text = message.text as String;

    return GestureDetector(
      onTap: () => context.go('/voice-chat'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: hairline, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.history_rounded,
                size: 18,
                color: isDark ? AppColors.dMuted : AppColors.muted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '"$text"',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 13.5,
                  color: isDark ? AppColors.dText : AppColors.ink,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              whenLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 11.5,
                color: const Color(0xFF9AA1B0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Flight picker view (no flight selected — preserved + re-skinned)
// ─────────────────────────────────────────────────────────────────────────────

class _FlightPickerView extends ConsumerWidget {
  final String detectedAirport;
  final bool isDark;
  final ValueChanged<String> onChangeAirport;
  final ValueChanged<Flight> onSelectFlight;

  const _FlightPickerView({
    required this.detectedAirport,
    required this.isDark,
    required this.onChangeAirport,
    required this.onSelectFlight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final upcomingFlights = ref.watch(upcomingFlightsProvider);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _TopBar(
          detectedAirport: detectedAirport,
          airports: HomeScreen._airports,
          onChangeAirport: onChangeAirport,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(_gutter, 8, _gutter, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _timeGreeting(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Departing soon',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  color: isDark ? AppColors.dText : AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select your flight for personalized routes & offers',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        if (upcomingFlights.isEmpty)
          _EmptyState(airport: detectedAirport, isDark: isDark)
        else
          ...upcomingFlights.map((flight) => Padding(
                padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, 12),
                child: _FlightCard(
                  flight: flight,
                  isDark: isDark,
                  onTap: () => onSelectFlight(flight),
                ),
              )),
        const SizedBox(height: 48),
      ],
    );
  }

  static String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Flight card (picker view)
// ─────────────────────────────────────────────────────────────────────────────

class _FlightCard extends StatelessWidget {
  final Flight flight;
  final bool isDark;
  final VoidCallback onTap;

  const _FlightCard({
    required this.flight,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm');
    final now = DateTime.now();
    final minutesUntil = flight.departureTime.difference(now).inMinutes;
    final timeUntil = minutesUntil >= 60
        ? '${minutesUntil ~/ 60}h ${minutesUntil % 60}m'
        : '${minutesUntil}m';
    final urgent = minutesUntil <= 60;
    final cardBg = isDark ? AppColors.dSurface : AppColors.card;
    final hairline = isDark ? AppColors.dHairline : AppColors.hairline;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Ink(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: hairline, width: 1),
            boxShadow: AppShadows.card,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.skyAlpha15 : AppColors.skyAlpha10,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Icon(Icons.flight_rounded,
                          color: isDark ? AppColors.dSky : AppColors.sky,
                          size: 18),
                    ),
                    const SizedBox(width: AppSpacing.smMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            flight.flightNumber,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.dText : AppColors.ink,
                            ),
                          ),
                          Text(
                            flight.airline,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusPill(
                      status: flight.status,
                      delayMinutes: flight.delayMinutes,
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.smMd),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flight.departureAirport,
                          style: AppTypography.mono(
                            fontSize: 18,
                            weight: FontWeight.w700,
                            color: isDark ? AppColors.dText : AppColors.ink,
                          ),
                        ),
                        Text(timeFormat.format(flight.departureTime),
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: AppColors.muted)),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: urgent
                                    ? AppColors.errorAlpha15
                                    : isDark
                                        ? AppColors.skyAlpha10
                                        : AppColors.skyAlpha10,
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusFull),
                              ),
                              child: Text(
                                'in $timeUntil',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: urgent
                                      ? AppColors.error
                                      : isDark
                                          ? AppColors.dSky
                                          : AppColors.sky,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                    child: Container(
                                        height: 1, color: isDark ? AppColors.dHairline : AppColors.hairline)),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(Icons.flight_takeoff_rounded,
                                      size: 14,
                                      color: isDark
                                          ? AppColors.dMuted
                                          : AppColors.muted),
                                ),
                                Expanded(
                                    child: Container(
                                        height: 1, color: isDark ? AppColors.dHairline : AppColors.hairline)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          flight.arrivalAirport,
                          style: AppTypography.mono(
                            fontSize: 18,
                            weight: FontWeight.w700,
                            color: isDark ? AppColors.dText : AppColors.ink,
                          ),
                        ),
                        Text(flight.arrivalCity,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: AppColors.muted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.smMd),
                Row(
                  children: [
                    if (flight.gate != null) ...[
                      Icon(Icons.door_sliding_rounded,
                          size: 14,
                          color: isDark ? AppColors.dMuted : AppColors.muted),
                      const SizedBox(width: 4),
                      Text('Gate ${flight.gate}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted)),
                      const SizedBox(width: AppSpacing.smMd),
                    ],
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Select',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark ? AppColors.dSky : AppColors.sky,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.chevron_right_rounded,
                            color: isDark ? AppColors.dSky : AppColors.sky,
                            size: 16),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status pill (shared)
// ─────────────────────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final String status;
  final int? delayMinutes;
  final bool isDark;

  const _StatusPill({
    required this.status,
    this.delayMinutes,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, textColor, bgColor) = switch (status) {
      'boarding' => ('Boarding', AppColors.sky, AppColors.skyAlpha15),
      'on_time' => ('On time', AppColors.success, AppColors.successAlpha15),
      'delayed' => (
          'Delayed ${delayMinutes ?? ""}m',
          AppColors.warning,
          AppColors.warningAlpha15,
        ),
      'cancelled' => ('Cancelled', AppColors.error, AppColors.errorAlpha15),
      'scheduled' => ('Scheduled', AppColors.muted, AppColors.inkAlpha10),
      'landed' => ('Landed', AppColors.ink, AppColors.inkAlpha10),
      _ => (status, AppColors.muted, AppColors.inkAlpha10),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: textColor),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String airport;
  final bool isDark;
  const _EmptyState({required this.airport, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _gutter),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: BoxDecoration(
          color: isDark ? AppColors.dSurface : AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
              color: isDark ? AppColors.dHairline : AppColors.hairline,
              width: 1),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.dSurfaceVariant : AppColors.skyAlpha10,
              ),
              child: Icon(Icons.flight_takeoff_rounded,
                  size: 30,
                  color: isDark ? AppColors.dMuted : AppColors.muted),
            ),
            const SizedBox(height: 12),
            Text(
              'No upcoming flights',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              'Nothing departing $airport in the next 3.5h',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
