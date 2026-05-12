import 'package:go_router/go_router.dart';

// main route
import 'package:hackathon/pages/home/home.dart';

import 'package:hackathon/pages/home/home_page.dart';
import 'package:hackathon/pages/journal/journal_page.dart';
import 'package:hackathon/pages/partner/partner_page.dart';
import 'package:hackathon/pages/profile/profile_page.dart';

// sub route
import 'package:hackathon/pages/onboarding/welcome_page.dart';
import 'package:hackathon/pages/partner/chat_page.dart';
import 'package:hackathon/pages/partner/video_call_page.dart';
import 'package:hackathon/pages/auth/login_page.dart';
import 'package:hackathon/pages/auth/register_page.dart';
import 'package:hackathon/pages/auth/input_data_page.dart';

bool firstInstall = true;
bool token = false;

String get _initialLocation {
  if (firstInstall) return '/onboarding/welcome';
  if (!token) return '/login';
  return '/';
}

final GoRouter router = GoRouter(
  initialLocation: _initialLocation,
  routes: [
    GoRoute(
      path: '/onboarding/welcome',
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(path: '/input-data',
      builder: (context, state) => const InputDataPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Home(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/', builder: (context, state) => const HomePage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/partner',
            builder: (context, state) => const PartnerPage(),
            routes: [
              GoRoute(path: 'chat', builder: (context, state) {
                return ChatPage();
              }),
              GoRoute(path: 'video-call', builder: (context, state) {
                return const VideoCallPage();
              }),
            ]
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/journal',
            builder: (context, state) => const JournalPage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ]),
      ],
    ),
  ],
);
