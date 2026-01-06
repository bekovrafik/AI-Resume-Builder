import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/ui/main_scaffold.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/profile/screens/profile_edit_screen.dart';
import '../features/vault/screens/vault_screen.dart';
import '../features/builder/screens/resume_editor_screen.dart';
import '../features/chat/screens/chat_architect_screen.dart';
import '../features/onboarding/screens/splash_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/market/screens/market_screen.dart';
import '../features/export/screens/resume_preview_screen.dart';
import '../features/strategy/screens/interview_prep_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = GoRouter(
  navigatorKey: _rootNavigatorKey,
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
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    // ShellRoute for Tab Navigation
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/market',
          builder: (context, state) => const MarketScreen(),
        ),
        GoRoute(
          path: '/preview',
          builder: (context, state) =>
              const ResumePreviewScreen(resumeId: null),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) =>
                  ResumePreviewScreen(resumeId: state.pathParameters['id']),
            ),
          ],
        ),
        GoRoute(
          path: '/vault',
          builder: (context, state) => const VaultScreen(),
        ),
        GoRoute(
          path: '/builder/:id',
          builder: (context, state) =>
              ResumeEditorScreen(resumeId: state.pathParameters['id']),
        ),
      ],
    ),
    // Fullscreen Routes (No Bottom Nav)
    GoRoute(
      path: '/profile',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ProfileEditScreen(),
    ),
    GoRoute(
      path: '/chat',
      parentNavigatorKey:
          _rootNavigatorKey, // Chat usually overlay or full screen
      builder: (context, state) => const ChatArchitectScreen(),
    ),
    GoRoute(
      path: '/strategy',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const InterviewPrepScreen(),
    ),
  ],
);
