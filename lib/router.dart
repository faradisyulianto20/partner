import 'package:go_router/go_router.dart';

// Home Route
import 'package:hackathon/features/home/home.dart';
import 'package:hackathon/features/home/pages/emotion_description_page.dart';
import 'package:hackathon/features/home/pages/expression_analysis.dart';
import 'package:hackathon/features/home/pages/voice_input.dart';
import 'package:hackathon/features/home/pages/analysis_result.dart';
import 'package:hackathon/features/home/pages/home_page.dart';

// Partner Route
import 'package:hackathon/features/partner/pages/partner_page.dart';
// AI Partner
import 'package:hackathon/features/partner/pages/ai_partner_chat.dart';
import 'package:hackathon/features/partner/pages/ai_partner_voice.dart';
// Human Partner
import 'package:hackathon/features/partner/pages/human_partner.dart';
import 'package:hackathon/features/partner/pages/human_partner_video_call.dart';
import 'package:hackathon/features/partner/pages/human_partner_chat.dart';
import 'package:hackathon/features/partner/pages/human_partner_voice_call.dart';
import 'package:hackathon/features/partner/pages/human_partner_end_call.dart';

// Professional Partner
import 'package:hackathon/features/partner/pages/professional_partner.dart';

import 'package:hackathon/features/profile/profile_page.dart';
import 'package:hackathon/features/journal/journal_page.dart';

// sub route
import 'package:hackathon/features/onboarding/welcome_page.dart';
import 'package:hackathon/features/partner/pages/video_call.dart';
import 'package:hackathon/features/auth/login_page.dart';
import 'package:hackathon/features/auth/register_page.dart';
import 'package:hackathon/features/auth/input_data_page.dart';

bool firstInstall = true;
bool token = false;

String get _initialLocation {
  if (firstInstall) return '/onboarding/welcome';
  if (!token) return '/login';
  return '/home';
}

final GoRouter router = GoRouter(
  initialLocation: _initialLocation,
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
      builder: (context, state) => const InputDataPage(),
    ),

    // Route yang tidak memiliki navigation bar
    GoRoute(
      path: '/voice-input',
      builder: (context, state) => const VoiceInput(),
    ),
    GoRoute(
      path: '/partner/ai-partner/chat',
      builder: (context, state) => AIPartnerChat(),
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

    StatefulShellRoute.indexedStack(
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
                  path: 'analysis-result',
                  builder: (context, state) => const AnalysisResult(),
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
    ),
  ],
);
