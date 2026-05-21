import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/core/theme/app_gradients.dart';
import 'package:hackathon/features/partner/widgets/chat_content.dart';
import 'package:hackathon/features/partner/widgets/chat_footer.dart';

class Chat extends StatelessWidget {
  const Chat({super.key});

  void _handleVoice(BuildContext context) {
    context.go('/partner/human-partner/voice-call');
  }

  void _handleVideo(BuildContext context) {
    context.go('/partner/human-partner/vidoe-call');
  }

  Future<void> _handleEndChat(BuildContext context) async {
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text(
            'Akhiri Chat dengan Mulyono?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight(800),
              color: Color(0xFF1B517A),
            ),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppGradients.horizontal,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Akhiri'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2F5F8F),
                      side: const BorderSide(color: Color(0xFF2F5F8F)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (shouldEnd == true && context.mounted) {
      context.go('/partner');
    }
  }

  static const List<ChatMessage> _messages = [
    ChatMessage(
      isSender: false,
      message: 'Halo gimana kabarmu hari ini?',
      time: '02:15',
    ),
    ChatMessage(
      isSender: true,
      message:
          'Aku sangat lelah hari ini, aku capek banget dari kemarin aku tidur subuh terus ngerjain proyek GDGOC ini',
      time: '02:16',
    ),
    ChatMessage(
      isSender: false,
      message:
          'Turut berduka ya.. Saranku sih gausah dikerjain ya biar kamu bisa tidur cukup',
      time: '02:16',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: const Text('Mulyono'),
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
            IconButton(
              icon: const Icon(Icons.videocam_outlined),
              onPressed: () => _handleVideo(context),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _handleEndChat(context),
            ),
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: AppGradients.horizontal),
          ),
        ),
        body: Column(
          children: [
            ChatContent(messages: _messages),
            const ChatFooter(hintText: 'Kirim pesan'),
          ],
        ),
      ),
    );
  }
}
