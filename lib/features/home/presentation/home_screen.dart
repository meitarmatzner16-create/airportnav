import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boarding_pass_card.dart';
import '../../../core/widgets/nearby_card.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/state_views.dart';
import '../../../features/flight/domain/entities/flight.dart';
import '../../../features/flight/presentation/providers/flight_providers.dart';
import '../../../features/venues/presentation/providers/venue_providers.dart';
import '../../../features/voice_chat/presentation/providers/voice_chat_providers.dart';
import '../../../features/map/presentation/providers/map_providers.dart';

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
    final upcomingFlights = ref.watch(upcomingFlightsProvider);

    // Displayed flight = explicit selection ?? soonest upcoming
    final displayFlight = selectedFlight ?? upcomingFlights.firstOrNull;

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      body: SafeArea(
        child: _DashboardView(
          flight: displayFlight,
          detectedAirport: detectedAirport,
          isDark: isDark,
          onChangeAirport: (v) {
            ref.read(detectedAirportProvider.notifier).state = v;
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard (flight selected)
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardView extends ConsumerWidget {
  final Flight? flight;
  final String detectedAirport;
  final bool isDark;
  final ValueChanged<String> onChangeAirport;

  const _DashboardView({
    required this.flight,
    required this.detectedAirport,
    required this.isDark,
    required this.onChangeAirport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final venues = ref.watch(allVenuesProvider);
    final nearbyVenues = venues.take(5).toList();

    // Voice chat: check for real route plan (active plan) and history
    final currentPlan = ref.watch(currentItineraryProvider);
    final chatMessages = ref.watch(voiceChatMessagesProvider);
    // Only show Recent plans if user has exchanged messages (beyond the greeting)
    final hasHistory = chatMessages.length > 1;

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
        ScreenHeader(
          greeting: _timeGreeting(),
          title: flight != null ? flight!.arrivalCity : 'Your flights',
          subtitle: flight != null
              ? '${DateFormat('d MMM yyyy').format(flight!.departureTime)} · ${flight!.flightNumber}'
              : null,
          actions: [
            TonalPill(
              label: 'Flights',
              icon: Icons.format_list_bulleted_rounded,
              onTap: () => context.push('/flights'),
            ),
          ],
        ),

        // ── Boarding pass card (or empty state if no flights) ─────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _gutter),
          child: flight != null
              ? BoardingPassCard(
                  flight: flight!,
                  onTap: () => context.push('/boarding-pass'),
                )
              : EmptyState(
                  icon: Icons.flight_takeoff_rounded,
                  title: 'No upcoming flights',
                  message: 'Add your flight to get personalised routes & offers.',
                  action: GestureDetector(
                    onTap: () => context.push('/flights'),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.skyAlpha15
                            : AppColors.skyTint,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.format_list_bulleted_rounded,
                            size: 16,
                            color: isDark ? AppColors.dSky : AppColors.sky,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'To flights board',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: isDark ? AppColors.dSky : AppColors.sky,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),

        const SizedBox(height: _sectionGap),

        // ── Voice CTA card ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _gutter),
          child: _VoiceCtaCard(isDark: isDark),
        ),

        const SizedBox(height: _sectionGap),

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
          padding: const EdgeInsets.symmetric(horizontal: _gutter),
          child: SectionHeader(
            title: 'Near your gate',
            actionText: 'See all',
            onAction: () => context.go('/venues'),
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
            child: SectionHeader(title: 'Recent plans'),
          ),
          const SizedBox(height: 4),
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
          // ── "Flights board" tonal pill ──────────────────────────────
          Semantics(
            label: 'Flights board',
            button: true,
            child: GestureDetector(
              onTap: () => context.push('/flights'),
              behavior: HitTestBehavior.opaque,
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.smMd, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.skyAlpha15
                      : AppColors.skyTint,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.format_list_bulleted_rounded,
                      size: 14,
                      color: isDark ? AppColors.dSky : AppColors.sky,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Flights',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isDark ? AppColors.dSky : AppColors.sky,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
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
// Active route preview card (conditional)
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveRouteCard extends ConsumerWidget {
  final dynamic plan; // RoutePlan
  final bool isDark;

  const _ActiveRouteCard({required this.plan, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      onTap: () {
        ref.read(activeRoutePlanProvider.notifier).state = plan;
        context.push('/navigate');
      },
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


