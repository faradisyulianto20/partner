import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/core/models/ai_partner_models.dart';
import 'package:hackathon/core/services/ai_partner_service.dart';
import 'package:hackathon/core/services/api_client.dart';
import 'package:hackathon/core/services/auth_state.dart';
import 'package:hackathon/core/constants.dart';
import 'package:hackathon/core/shared_widgets/header.dart';
import 'package:hackathon/features/client/partner/widgets/ai_partner.dart';
import 'package:hackathon/features/client/partner/widgets/professional_partner.dart';
import 'package:hackathon/features/client/partner/widgets/human_partner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PartnerPage extends StatefulWidget {
  final void Function(String chatId)? onStartChat;
  const PartnerPage({super.key, this.onStartChat});

  @override
  State<PartnerPage> createState() => _PartnerPageState();
}

class _PartnerPageState extends State<PartnerPage> {
  static final String _baseUrl = AppConstants.baseUrl;

  static String _userSessionKey() =>
      'ai_chat_session_id_${authState.userId}';

  late final ApiClient _apiClient = ApiClient(baseUrl: _baseUrl);
  late final AiPartnerService _aiPartnerService = AiPartnerService(_apiClient);
  bool _isStartingChat = false;

  @override
  void dispose() {
    _apiClient.close();
    super.dispose();
  }

  Future<void> _startAiChat(BuildContext context) async {
    if (_isStartingChat) return;
    setState(() => _isStartingChat = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      String? sessionId = prefs.getString(_userSessionKey());

      // Jika belum ada sessionId, buat sesi baru
      if (sessionId == null) {
        final userId = authState.userId;
        final sessionResponse = await _aiPartnerService.createSession(
          AiChatSessionRequest(userId: userId, title: 'AI Partner Chat'),
        );
        if (!sessionResponse.isSuccess) {
          _showSnackBar('Gagal membuat sesi chat.');
          return;
        }

        final sessionData = sessionResponse.data.data;
        final sessionMap = sessionData is Map
            ? Map<String, dynamic>.from(sessionData)
            : null;
        sessionId = sessionMap?['id']?.toString();
        if (sessionId == null || sessionId.isEmpty) {
          _showSnackBar('Sesi chat tidak valid.');
          return;
        }

        await prefs.setString(_userSessionKey(), sessionId);
      }

      if (!context.mounted) return;
      context.push('/partner/ai-partner/chat', extra: {'sessionId': sessionId});
    } catch (_) {
      _showSnackBar('Terjadi kesalahan saat memulai chat.');
    } finally {
      if (!mounted) return;
      setState(() => _isStartingChat = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: [
          Header(
            userName: 'Dinda',
            greeting: 'Selamat Pagi',
            onProfileTap: () {
              // Navigate to profile
            },
          ),
          const SizedBox(height: 16),
          AIPartner(
            onChat: _isStartingChat ? null : () => _startAiChat(context),
          ),
          const SizedBox(height: 14),
          HumanPartner(),
          const SizedBox(height: 16),
          const ProfessionalPartner(),
        ],
      ),
    );
  }
}
