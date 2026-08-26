import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/map/presentation/screens/airport_map_screen.dart';
import '../../features/map/presentation/screens/route_navigation_screen.dart';
import '../../features/offers/presentation/screens/offers_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../features/voice_chat/presentation/screens/voice_chat_screen.dart';
import '../../features/flight/presentation/screens/flight_detail_screen.dart';
import '../../features/flight/presentation/screens/flights_board_screen.dart';
import '../../features/journey/presentation/screens/journey_screen.dart';
import '../../features/journey/presentation/screens/journey_steps_screen.dart';
import '../../features/venues/presentation/screens/explore_screen.dart';
import '../../features/venues/presentation/screens/venue_detail_screen.dart';
import '../widgets/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Guided route navigation (pushed from RoutePlanCard / Active plan card)
      GoRoute(
        path: '/navigate',
        builder: (context, state) => const RouteNavigationScreen(),
      ),
      // Full-screen venue detail (pushed from Explore)
      GoRoute(
        path: '/explore/venue/:id',
        builder: (context, state) => VenueDetailScreen(
          venueId: state.pathParameters['id']!,
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
            routes: [
              GoRoute(
                path: 'flight/:flightId',
                builder: (context, state) => FlightDetailScreen(
                  flightId: state.pathParameters['flightId']!,
                ),
              ),
            ],
          ),
          // Map tab (was a standalone route; now lives in the tab shell)
          GoRoute(
            path: '/map',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AirportMapScreen(),
            ),
          ),
          // Reached from the journey's first step, not from the tab bar.
          // builder (not NoTransitionPage) so a push animates normally.
          GoRoute(
            path: '/flights',
            builder: (context, state) => const FlightsBoardScreen(),
          ),
          // Trip tab - the journey, wherever you are in it.
          GoRoute(
            path: '/journey',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: JourneyScreen(),
            ),
            routes: [
              GoRoute(
                path: 'steps',
                builder: (context, state) => const JourneyStepsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/voice-chat',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VoiceChatScreen(),
            ),
          ),
          // Non-tab shell routes - reachable from Home / profile, keep the bar.
          GoRoute(
            path: '/offers',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OffersScreen(),
            ),
          ),
          GoRoute(
            path: '/explore',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ExploreScreen(),
            ),
          ),
          GoRoute(
            path: '/more',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MoreScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
