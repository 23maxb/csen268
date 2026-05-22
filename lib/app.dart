import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'feature_flags.dart';
import 'pages/calendar_page.dart';
import 'pages/home_page.dart';
import 'pages/inventory_page.dart';
import 'pages/chat_page.dart';
import 'pages/login_page.dart';
import 'pages/messages_page.dart';
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
      path: '/recipe/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return RecipePage(
          id: id,
          initialTitle: state.uri.queryParameters['title'],
          initialImage: state.uri.queryParameters['image'],
        );
      },
    ),
    GoRoute(
      path: '/messages/:chatId',
      builder: (context, state) => ChatPage(
        chatId: state.pathParameters['chatId']!,
        otherEmail: state.uri.queryParameters['email'] ?? '',
      ),
    ),
    ShellRoute(
      builder: (context, state, child) =>
          MainScaffold(location: state.matchedLocation, child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomePage()),
        ),
        if (kCalendarEnabled)
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CalendarPage()),
          ),
        GoRoute(
          path: '/inventory',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: InventoryPage()),
        ),
        GoRoute(
          path: '/messages',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: MessagesPage()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SettingsPage()),
        ),
      ],
    ),
  ],
);
