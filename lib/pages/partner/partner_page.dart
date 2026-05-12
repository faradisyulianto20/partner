import 'package:flutter/material.dart';
import 'package:hackathon/widgets/partner/ai_partner.dart';
import 'package:hackathon/widgets/partner/greetings.dart';
import 'package:hackathon/widgets/partner/human_partner.dart';

class PartnerPage extends StatelessWidget {
  final void Function(String chatId)? onStartChat;
  const PartnerPage({super.key, this.onStartChat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Greetings(),
              const AIPartner(),
              HumanPartner(
                onStartChat: onStartChat != null
                    ? () => onStartChat!("chat123")
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
