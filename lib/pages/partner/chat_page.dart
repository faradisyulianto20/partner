import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/widgets/partner/chat_content.dart';
import 'package:hackathon/widgets/partner/chat_footer.dart';
import 'package:hackathon/widgets/partner/chat_header.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  void _handleVideoCall(BuildContext context) {
    context.go('/partner/video-call');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Chat'),
            Row(
              children: [
                Icon(Icons.phone),
                SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _handleVideoCall(context),
                  child: Icon(Icons.videocam),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [ChatHeader(), ChatContent(), ChatFooter()],
        ),
      ),
    );
  }
}
