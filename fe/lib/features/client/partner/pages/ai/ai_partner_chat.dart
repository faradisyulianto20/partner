import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/core/models/ai_partner_models.dart';
import 'package:hackathon/core/services/ai_partner_service.dart';
import 'package:hackathon/core/services/api_client.dart';
import 'package:hackathon/core/theme/app_gradients.dart';
import 'package:hackathon/features/client/partner/widgets/chat_content.dart';
import 'package:hackathon/features/client/partner/widgets/chat_footer.dart';
import 'package:hackathon/core/constants.dart';
import 'package:hackathon/core/services/auth_state.dart';

class AIPartnerChat extends StatefulWidget {
  const AIPartnerChat({super.key, this.sessionId, this.initialMessages});

  final String? sessionId;
  final List<ChatMessage>? initialMessages;

  @override
  State<AIPartnerChat> createState() => _AIPartnerChatState();
}

class _AIPartnerChatState extends State<AIPartnerChat> {
  static final String _baseUrl = AppConstants.baseUrl;

  late final ApiClient _apiClient = ApiClient(baseUrl: _baseUrl);
  late final AiPartnerService _aiPartnerService = AiPartnerService(_apiClient);
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _sessionId;
  bool _isLoading = true;
  bool _isSending = false;
  String? _errorMessage;
  final List<ChatMessage> _messages = [];

  void _handleVoice(BuildContext context) {
    context.push('/partner/ai-partner/voice');
  }

  @override
  void initState() {
    super.initState();
    _bootstrapSession();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _apiClient.close();
    super.dispose();
  }

  Future<void> _bootstrapSession() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final sessionId = widget.sessionId;
    if (sessionId == null || sessionId.isEmpty) {
      setState(() {
        _errorMessage = 'Sesi chat belum tersedia.';
        _isLoading = false;
      });
      return;
    }

    // Fetch GET session untuk ambil data terbaru + id yang valid
    debugPrint('🔍 GET session — sessionId: $sessionId');
    try {
      final response = await _aiPartnerService
          .getSession(sessionId)
          .timeout(const Duration(seconds: 12));
      debugPrint('📥 GET session response — sessionId: $sessionId | success: ${response.isSuccess} | data: ${response.data?.data}');

      if (!response.isSuccess) {
        setState(() {
          _errorMessage = 'Gagal memuat sesi chat.';
          _isLoading = false;
        });
        return;
      }

      final data = response.data.data;
      final map = data is Map ? Map<String, dynamic>.from(data) : null;

      // Ambil id dari response (pastikan pakai id yang benar)
      _sessionId = map?['id']?.toString() ?? sessionId;

      final items = <ChatMessage>[];
      final messages = map?['messages'];
      if (messages is List) {
        for (final item in messages) {
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

      if (items.isEmpty) {
        items.add(
          const ChatMessage(
            isSender: false,
            message:
                'Halo, aku siap mendengarkanmu. Apa yang sedang kamu rasakan hari ini?',
            time: '--:--',
          ),
        );
      }

      setState(() {
        _messages
          ..clear()
          ..addAll(items);
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan. Coba lagi.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSessionMessages(String sessionId) async {
    final response = await _aiPartnerService
        .getSession(sessionId)
        .timeout(const Duration(seconds: 12));
    if (!response.isSuccess) {
      _showSnackBar('Gagal memuat riwayat chat.');
      setState(() => _errorMessage = 'Gagal memuat riwayat chat.');
      return;
    }

    print('── Session Detail Data ──────────────────────');
    print(response.data.data);
    print('──────────────────────────────────────────────');
    final data = response.data.data;
    final map = data is Map ? Map<String, dynamic>.from(data) : null;
    final items = <ChatMessage>[];
    final messages = map?['messages'];
    if (messages is List) {
      for (final item in messages) {
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

    if (items.isEmpty) {
      items.add(
        const ChatMessage(
          isSender: false,
          message:
              'Halo, aku siap mendengarkanmu. Apa yang sedang kamu rasakan hari ini?',
          time: '--:--',
        ),
      );
    }

    setState(() {
      _messages
        ..clear()
        ..addAll(items);
    });
  }

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSending) return;

    final sessionId = _sessionId;
    if (sessionId == null) {
      _showSnackBar('Sesi chat belum siap.');
      return;
    }

    setState(() => _isSending = true);
    _textController.clear();

    _messages.add(
      ChatMessage(
        isSender: true,
        message: text,
        time: _formatTime(DateTime.now().toIso8601String()),
      ),
    );
    setState(() {});
    _scrollToBottom();

    try {
      debugPrint('📤 POST message — sessionId: $sessionId | content: $text');
      final response = await _aiPartnerService
          .sendMessage(
            sessionId,
            AiChatMessageRequest(content: text), // ← hapus userId
          )
          .timeout(const Duration(seconds: 30)); // ← naikkan ke 30 detik
      debugPrint('📥 POST message response — sessionId: $sessionId | success: ${response.isSuccess} | data: ${response.data?.data}');

      if (!response.isSuccess) {
        _showSnackBar('Gagal mengirim pesan.');
        return;
      }

      final data = response.data.data;
      final map = data is Map ? Map<String, dynamic>.from(data) : null;

      // Response sendMessage adalah assistant message langsung
      // { id, sessionId, role: 'assistant', content, createdAt }
      final reply =
          map?['content']?.toString() ??
          'Maaf, aku belum bisa menjawab sekarang.';

      _messages.add(
        ChatMessage(
          isSender: false,
          message: reply,
          time: _formatTime(map?['createdAt']?.toString()),
        ),
      );
    } catch (e) {
      _showSnackBar('Terjadi kesalahan saat mengirim pesan.');
    } finally {
      if (!mounted) return;
      setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  String? _currentUserId() {
    return authState.userId;
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: const Text('AI Partner Chat'),
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.graphic_eq_rounded),
              onPressed: () => _handleVoice(context),
            ),
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: AppGradients.horizontal),
          ),
        ),
        body: Column(
          children: [
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_errorMessage != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _bootstrapSession,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ChatContent(messages: _messages, controller: _scrollController),
            ChatFooter(
              controller: _textController,
              onSend: _handleSend,
              isSending: _isSending,
            ),
          ],
        ),
      ),
    );
  }
}
