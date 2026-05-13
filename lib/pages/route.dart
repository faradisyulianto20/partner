import 'package:go_router/go_router.dart';

import 'package:hackathon/pages/home/home_page.dart';
import 'package:hackathon/pages/partner/partner_page.dart';
import 'package:hackathon/pages/journal/journal_page.dart';
import 'package:hackathon/pages/profile/profile_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(path: '/partner', builder: (context, state) => const PartnerPage()),
    GoRoute(path: '/journal', builder: (context, state) => const JournalPage()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
  ],
);
