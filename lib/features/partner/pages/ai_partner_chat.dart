import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/core/theme/app_gradients.dart';
import 'package:hackathon/features/partner/widgets/chat_content.dart';
import 'package:hackathon/features/partner/widgets/chat_footer.dart';

class AIPartnerChat extends StatelessWidget {
  const AIPartnerChat({super.key});

  // void _handleVideoCall(BuildContext context) {
  //   context.go('/partner/video-call');
  // }

  void _handleVoice(BuildContext context) {
    context.go('/partner/ai-partner/voice');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Column(children: [ChatContent(), ChatFooter()]),
    );
  }
}
