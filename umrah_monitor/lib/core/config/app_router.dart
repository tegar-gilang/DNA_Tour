import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/role_selection_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/pilgrim/presentation/pilgrim_shell.dart';
import '../../features/pilgrim/presentation/pilgrim_home_screen.dart';
import '../../features/pilgrim/presentation/pilgrim_schedule_screen.dart';
import '../../features/pilgrim/presentation/pilgrim_profile_screen.dart';
import '../../features/family/presentation/family_shell.dart';
import '../../features/family/presentation/family_home_screen.dart';
import '../../features/family/presentation/family_updates_screen.dart';
import '../../features/family/presentation/family_profile_screen.dart';
import '../../features/tour_leader/presentation/tour_leader_shell.dart';
import '../../features/tour_leader/presentation/tour_leader_dashboard_screen.dart';
import '../../features/tour_leader/presentation/pilgrim_management_screen.dart';
import '../../features/tour_leader/presentation/tour_leader_schedule_screen.dart';
import '../../features/tour_leader/presentation/incident_management_screen.dart';
import '../../features/tour_leader/presentation/tour_leader_profile_screen.dart';
import '../../features/tracking/presentation/interactive_map_screen.dart';
import '../../features/tracking/presentation/sos_emergency_screen.dart';
import '../../features/common/presentation/messages_screen.dart';
import '../../features/common/presentation/notifications_screen.dart';
import '../../features/prayer/domain/prayer_model.dart';
import '../../features/prayer/presentation/prayer_collection_screen.dart';
import '../../features/prayer/presentation/prayer_detail_screen.dart';
import '../../features/tasbih/presentation/digital_tasbih_screen.dart';
import '../../features/prayer_time/presentation/prayer_time_screen.dart';
import '../../features/guide/presentation/umrah_guide_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      redirect: (context, state) => '/role_selection',
    ),
    GoRoute(
      path: '/role_selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),

    // Pilgrim Shell Navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return PilgrimShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/pilgrim',
              builder: (context, state) => const PilgrimHomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/pilgrim/schedule',
              builder: (context, state) => const PilgrimScheduleScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/pilgrim/map',
              builder: (context, state) => const InteractiveMapScreen(isTourLeaderView: false),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/pilgrim/messages',
              builder: (context, state) => const MessagesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/pilgrim/profile',
              builder: (context, state) => const PilgrimProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // Family Shell Navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return FamilyShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/family',
              builder: (context, state) => const FamilyHomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/family/location',
              builder: (context, state) => const InteractiveMapScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/family/updates',
              builder: (context, state) => const FamilyUpdatesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/family/messages',
              builder: (context, state) => const MessagesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/family/profile',
              builder: (context, state) => const FamilyProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // Tour Leader Shell Navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return TourLeaderShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tour_leader',
              builder: (context, state) => const TourLeaderDashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tour_leader/pilgrims',
              builder: (context, state) => const PilgrimManagementScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tour_leader/schedule',
              builder: (context, state) => const TourLeaderScheduleScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tour_leader/map',
              builder: (context, state) => const InteractiveMapScreen(isTourLeaderView: true),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tour_leader/profile',
              builder: (context, state) => const TourLeaderProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: '/tour_leader/messages',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const MessagesScreen(),
    ),

    // Standalone Modals / Fullscreen Tools
    GoRoute(
      path: '/tour_leader/incidents',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const IncidentManagementScreen(),
    ),
    GoRoute(
      path: '/sos',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SosEmergencyScreen(),
    ),
    GoRoute(
      path: '/notifications',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/prayer_collection',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PrayerCollectionScreen(),
    ),
    GoRoute(
      path: '/prayer_detail/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final prayer = (state.extra is PrayerModel) ? (state.extra as PrayerModel) : PrayerModel.masterCollection.first;
        return PrayerDetailScreen(prayer: prayer);
      },
    ),
    GoRoute(
      path: '/digital_tasbih',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const DigitalTasbihScreen(),
    ),
    GoRoute(
      path: '/prayer_time',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PrayerTimeScreen(),
    ),
    GoRoute(
      path: '/umrah_guide',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const UmrahGuideScreen(),
    ),
  ],
);
