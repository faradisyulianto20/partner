import 'package:flutter/material.dart';
import 'package:hackathon/core/widgets/header.dart';
import 'package:hackathon/features/partner/widgets/ai_partner.dart';
import 'package:hackathon/features/partner/widgets/ai_professional.dart';
import 'package:hackathon/features/partner/widgets/human_partner.dart';

class PartnerPage extends StatelessWidget {
  final void Function(String chatId)? onStartChat;
  const PartnerPage({super.key, this.onStartChat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: SingleChildScrollView(
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
                onChat: onStartChat != null
                    ? () => onStartChat!("chat123")
                    : null,
              ),
              const SizedBox(height: 16),
              HumanPartner(
                onFindPartner: onStartChat != null
                    ? () => onStartChat!("chat123")
                    : null,
              ),
              const SizedBox(height: 16),
              const AIProfessional(),
            ],
          ),
        ),
      ),
    );
  }
}
