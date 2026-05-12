import 'package:go_router/go_router.dart';

import 'pages/calendar_page.dart';
import 'pages/home_page.dart';
import 'pages/inventory_page.dart';
import 'pages/login_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/recipe_page.dart';
import 'pages/register_page.dart';
import 'pages/settings_page.dart';
import 'widgets/main_scaffold.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/recipe',
      builder: (context, state) => const RecipePage(),
    ),
    ShellRoute(
      builder: (context, state, child) =>
          MainScaffold(location: state.matchedLocation, child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarPage(),
        ),
        GoRoute(
          path: '/inventory',
          builder: (context, state) => const InventoryPage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),
  ],
);
