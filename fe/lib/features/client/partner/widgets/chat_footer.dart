import 'package:flutter/material.dart';
import 'package:hackathon/core/theme/app_gradients.dart';

class ChatFooter extends StatelessWidget {
  const ChatFooter({
    super.key,
    this.hintText = 'Ceritakan bagaimana perasaanmu...',
    this.controller,
    this.onSend,
    this.isSending = false,
  });

  final String hintText;
  final TextEditingController? controller;
  final VoidCallback? onSend;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF3A7CA5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                prefixIcon: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add_rounded),
                ),
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 66,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppGradients.horizontal,
              borderRadius: BorderRadius.circular(32),
            ),
            child: IconButton(
              icon: isSending
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: isSending ? null : onSend,
            ),
          ),
        ],
      ),
    );
  }
}
