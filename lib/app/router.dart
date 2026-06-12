import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/providers.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/diary/diary_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/settings/alert_thresholds_screen.dart';
import '../features/settings/notification_settings_screen.dart';
import '../features/shell/main_shell.dart';
import '../features/subscription/subscription_screen.dart';
import '../features/calibration/presentation/calibration_screen.dart';
import '../features/doctor_link/presentation/doctor_link_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = auth.isAuthenticated;
      final onboardingComplete = auth.onboardingComplete;
      final path = state.matchedLocation;

      const authRoutes = {'/login', '/register'};
      const appRoutes = {
        '/home',
        '/analytics',
        '/alerts',
        '/device',
        '/profile',
        '/diary',
        '/subscription',
        '/notification-settings',
        '/alert-thresholds',
        '/calibration',
        '/calibration-complete',
        '/doctor-link',
      };

      final isAuthRoute = authRoutes.contains(path);
      final isOnboarding = path == '/onboarding';
      final isAppRoute = appRoutes.contains(path);

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && !onboardingComplete && !isOnboarding) {
        return '/onboarding';
      }
      if (isAuthenticated &&
          onboardingComplete &&
          (isAuthRoute || isOnboarding)) {
        return '/home';
      }
      if (isAuthenticated && onboardingComplete && !isAppRoute && !isAuthRoute) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/diary',
        builder: (context, state) => const DiaryScreen(),
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/notification-settings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/alert-thresholds',
        builder: (context, state) => const AlertThresholdsScreen(),
      ),
      GoRoute(
        path: '/calibration',
        builder: (context, state) => const CalibrationScreen(),
      ),
      GoRoute(
        path: '/calibration-complete',
        builder: (context, state) => const CalibrationCompleteScreen(),
      ),
      GoRoute(
        path: '/doctor-link',
        builder: (context, state) => const DoctorLinkScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => mainShellBranches[0],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (context, state) => mainShellBranches[1],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/alerts',
                builder: (context, state) => mainShellBranches[2],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/device',
                builder: (context, state) => mainShellBranches[3],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => mainShellBranches[4],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
