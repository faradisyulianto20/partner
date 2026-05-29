import 'package:go_router/go_router.dart';
import 'package:hackathon/features/client/home/pages/home_page.dart';

// Home Route
import 'package:hackathon/features/client/home/home.dart';
import 'package:hackathon/features/client/home/pages/emotion_description_page.dart';
import 'package:hackathon/features/client/home/pages/expression_analysis.dart';
import 'package:hackathon/features/client/home/pages/voice_input.dart';
import 'package:hackathon/features/client/home/pages/analysis_result.dart';
import 'package:hackathon/features/client/home/pages/home_page.dart';
import 'package:hackathon/features/client/home/widgets/cta.dart';
import 'package:hackathon/core/models/analysis_models.dart';

// Partner Route
import 'package:hackathon/features/client/partner/pages/partner_page.dart';
// AI Partner
import 'package:hackathon/features/client/partner/pages/ai/ai_partner_chat.dart';
import 'package:hackathon/features/client/partner/widgets/chat_content.dart';
import 'package:hackathon/features/client/partner/pages/ai/ai_partner_voice.dart';
// Human Partner
import 'package:hackathon/features/client/partner/pages/human/human_partner.dart';
import 'package:hackathon/features/client/partner/pages/human/human_partner_video_call.dart';
import 'package:hackathon/features/client/partner/pages/human/human_partner_chat.dart';
import 'package:hackathon/features/client/partner/pages/human/human_partner_voice_call.dart';
import 'package:hackathon/features/client/partner/pages/human/human_partner_end_call.dart';

// Professional Partner
import 'package:hackathon/features/client/partner/pages/professional/professional_partner.dart';
import 'package:hackathon/features/client/partner/pages/professional/professional_partner_detail.dart';
import 'package:hackathon/features/client/partner/pages/professional/professional_partner_booking.dart';

import 'package:hackathon/features/client/profile/profile_page.dart';
import 'package:hackathon/features/client/journal/journal_page.dart';
import 'package:hackathon/features/client/journal/journal_add.dart';

// sub route
import 'package:hackathon/features/onboarding/welcome_page.dart';
import 'package:hackathon/features/client/partner/pages/human/video_call.dart';
import 'package:hackathon/features/auth/presentation/login_page.dart';
import 'package:hackathon/features/auth/presentation/register_page.dart';
import 'package:hackathon/features/auth/presentation/input_data_page.dart';
import 'package:hackathon/core/state/user_role_state.dart';

import 'package:hackathon/features/psikolog/home/home_page.dart';
import 'package:hackathon/features/psikolog/schedule/schedule_page.dart';
import 'package:hackathon/features/psikolog/client/client_page.dart';

import 'package:hackathon/features/psikolog/profile/profile_page.dart';
import 'package:hackathon/features/psikolog/profile/review.dart';
import 'package:hackathon/features/psikolog/profile/income.dart';
import 'package:hackathon/features/psikolog/profile/schedule.dart';
import 'package:hackathon/features/psikolog/profile/profile_service.dart';

import 'package:hackathon/core/services/auth_state.dart';

bool firstInstall = true;

bool get _isLoggedIn => authState.isLoggedIn;

String get _initialLocation {
  if (firstInstall) return '/onboarding/welcome';
  if (!_isLoggedIn) return '/login';
  return '/home';
}

final GoRouter router = GoRouter(
  initialLocation: _initialLocation,
  observers: [homeRouteObserver],
  redirect: (context, state) {
    if (firstInstall || !_isLoggedIn) return null;

    final isPsychologist = userRoleState.isPsychologist;
    final loggingInOrOnboarding =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/onboarding/welcome';

    if (loggingInOrOnboarding) {
      return isPsychologist ? '/psychologist/home' : '/home';
    }

    // 3. JAGA: Jika Client mencoba masuk ke path psikolog
    if (!isPsychologist && state.matchedLocation.startsWith('/psychologist')) {
      return '/home';
    }

    // 4. JAGA: Jika Psikolog mencoba masuk ke path client biasa
    if (isPsychologist &&
        (state.matchedLocation.startsWith('/home') ||
            state.matchedLocation.startsWith('/partner'))) {
      return '/psychologist/home';
    }

    return null;
  },

  routes: [
    // Introduction & Authentication Routes
    GoRoute(
      path: '/onboarding/welcome',
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/input-data',
      builder: (context, state) {
        final String? roleParam = state.uri.queryParameters['isPsychologist'];
        final bool isPsychologist = roleParam == null
            ? userRoleState.isPsychologist
            : roleParam == 'true';
        if (roleParam != null) {
          userRoleState.isPsychologist = isPsychologist;
        }
        return InputDataPage(isPsychologist: isPsychologist);
      },
    ),

    // Route yang tidak memiliki navigation bar
    GoRoute(
      path: '/voice-input',
      builder: (context, state) => const VoiceInput(),
    ),
    GoRoute(
      path: '/partner/ai-partner/chat',
      builder: (context, state) {
        final extra = state.extra;
        String? sessionId;
        List<ChatMessage>? messages;
        if (extra is Map) {
          sessionId = extra['sessionId']?.toString();
          final rawMessages = extra['messages'];
          if (rawMessages is List<ChatMessage>) {
            messages = rawMessages;
          }
        }
        return AIPartnerChat(sessionId: sessionId, initialMessages: messages);
      },
    ),
    GoRoute(
      path: '/partner/ai-partner/voice',
      builder: (context, state) => AIPartnerVoice(),
    ),
    GoRoute(
      path: '/partner/human-partner',
      builder: (context, state) => HumanPartnerPage(),
    ),
    GoRoute(
      path: '/partner/human-partner/video-call',
      builder: (context, state) => const VideoCall(),
    ),
    GoRoute(
      path: '/partner/human-partner/chat',
      builder: (context, state) => const Chat(),
    ),
    GoRoute(
      path: '/partner/human-partner/voice-call',
      builder: (context, state) => const VoiceCall(),
    ),
    GoRoute(
      path: '/partner/human-partner/end-call',
      builder: (context, state) => const EndCall(),
    ),
    GoRoute(
      path: '/partner/professional-partner/detail/:id',
      builder: (context, state) {
        final psychologistId = state.pathParameters['id'] ?? '';
        return DetailDoctor(psychologistId: psychologistId);
      },
    ),
    GoRoute(
      path: '/partner/professional-partner/booking',
      builder: (context, state) {
        final extra = state.extra;
        // if (extra is PsychologistDetailResponse) {
        //   return Booking(
        //     psychologistId: extra.id,
        //     psychologistName: extra.fullName,
        //     price: extra.price,
        //   );
        // }
        return const Booking(
          psychologistId: '',
          psychologistName: 'Unknown',
          price: 0,
        );
      },
    ),
    GoRoute(
      path: '/journal/add',
      builder: (context, state) => const JournalAdd(),
    ),
    GoRoute(
      path: '/psychologist/profile/schedule',
      builder: (context, state) => const Schedule(),
    ),
    GoRoute(
      path: '/psychologist/profile/profile-service',
      builder: (context, state) => const ProfileService(),
    ),
    GoRoute(
      path: '/psychologist/profile/income',
      builder: (context, state) => const Income(),
    ),
    clientShellRoute,
    psychologistShellRoute,
  ],
);

final clientShellRoute = StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) {
    return Home(navigationShell: navigationShell);
  },
  branches: [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              path: 'emotion-description',
              builder: (context, state) => const EmotionDescriptionPage(),
            ),
            GoRoute(
              path: 'expression-analysis',
              builder: (context, state) => const ExpressionAnalysis(),
            ),
            GoRoute(
              path: 'voice-input',
              builder: (context, state) => const VoiceInput(),
            ),
            GoRoute(
              path: '/analysis-result',
              builder: (context, state) =>
                  AnalysisResult(result: state.extra as AnalysisResultData?),
            ),
          ],
        ),
      ],
    ),

    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/partner',
          builder: (context, state) => const PartnerPage(),
          routes: [
            GoRoute(
              path: 'professional-partner',
              builder: (context, state) => ProfessionalPartnerPage(),
            ),

            GoRoute(
              path: 'video-call',
              builder: (context, state) {
                return const VideoCallPage();
              },
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/journal',
          builder: (context, state) => const JournalPage(),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
  ],
);

final psychologistShellRoute = StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) {
    return Home(navigationShell: navigationShell);
  },
  branches: [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/psychologist/home',
          builder: (context, state) =>
              const PsychologistHomePage(), // Halaman utama isi list pasien/jadwal
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/psychologist/schedule',
          builder: (context, state) =>
              const SchedulePage(), // Riwayat konsultasi selesai
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/psychologist/client',
          builder: (context, state) =>
              const ClientPage(), // Profil & pengaturan jadwal praktek
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/psychologist/profile',
          builder: (context, state) => const ProfilePsychologistPage(),
          routes: [
            GoRoute(path: 'review', builder: (context, state) => Review()),
          ], // Profil & pengaturan jadwal praktek
        ),
      ],
    ),
  ],
);
