import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/map/presentation/screens/airport_map_screen.dart';
import '../../features/offers/presentation/screens/offers_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../features/voice_chat/presentation/screens/voice_chat_screen.dart';
import '../../features/flight/presentation/screens/flight_search_screen.dart';
import '../../features/flight/presentation/screens/flight_detail_screen.dart';
import '../../features/venues/presentation/screens/venues_screen.dart';
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
      // Map as a standalone route (pushed from Venues "View Map" button)
      GoRoute(
        path: '/map',
        builder: (context, state) => const AirportMapScreen(),
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
                path: 'flight-search',
                builder: (context, state) => const FlightSearchScreen(),
              ),
              GoRoute(
                path: 'flight/:flightId',
                builder: (context, state) => FlightDetailScreen(
                  flightId: state.pathParameters['flightId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/offers',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OffersScreen(),
            ),
          ),
          GoRoute(
            path: '/voice-chat',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VoiceChatScreen(),
            ),
          ),
          GoRoute(
            path: '/venues',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VenuesScreen(),
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
