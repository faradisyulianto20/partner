import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/core/models/ai_partner_models.dart';
import 'package:hackathon/core/services/ai_partner_service.dart';
import 'package:hackathon/core/services/api_client.dart';
import 'package:hackathon/core/constants.dart';
import 'package:hackathon/core/shared_widgets/header.dart';
import 'package:hackathon/features/client/partner/widgets/ai_partner.dart';
import 'package:hackathon/features/client/partner/widgets/chat_content.dart';
import 'package:hackathon/features/client/partner/widgets/professional_partner.dart';
import 'package:hackathon/features/client/partner/widgets/human_partner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PartnerPage extends StatefulWidget {
  final void Function(String chatId)? onStartChat;
  const PartnerPage({super.key, this.onStartChat});

  @override
  State<PartnerPage> createState() => _PartnerPageState();
}

class _PartnerPageState extends State<PartnerPage> {
  static final String _baseUrl = AppConstants.baseUrl;

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
      final userId = Supabase.instance.client.auth.currentUser?.id;
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
      final sessionId = sessionMap?['id']?.toString();
      if (sessionId == null || sessionId.isEmpty) {
        _showSnackBar('Sesi chat tidak valid.');
        return;
      }

      final detailResponse = await _aiPartnerService.getSession(sessionId);
      if (!detailResponse.isSuccess) {
        _showSnackBar('Gagal memuat detail sesi chat.');
        return;
      }

      final detailData = detailResponse.data.data;
      final detailMap = detailData is Map
          ? Map<String, dynamic>.from(detailData)
          : null;
      final messages = _mapMessages(detailMap?['messages']);

      if (!context.mounted) return;
      context.go(
        '/partner/ai-partner/chat',
        extra: {'sessionId': sessionId, 'messages': messages},
      );
    } catch (_) {
      _showSnackBar('Terjadi kesalahan saat memulai chat.');
    } finally {
      if (!mounted) return;
      setState(() => _isStartingChat = false);
    }
  }

  List<ChatMessage> _mapMessages(Object? raw) {
    final items = <ChatMessage>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          final role = item['role']?.toString() ?? 'assistant';
          final content = item['content']?.toString() ?? '';
          final createdAt = item['createdAt']?.toString();
          items.add(
            ChatMessage(
              isSender: role == 'user',
              message: content,
              time: _formatTime(createdAt),
            ),
          );
        }
      }
    }
    return items;
  }

  String _formatTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) {
      return '--:--';
    }
    final parsed = DateTime.tryParse(isoString);
    if (parsed == null) {
      return '--:--';
    }
    final local = parsed.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
