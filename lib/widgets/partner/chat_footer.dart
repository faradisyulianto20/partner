import 'package:flutter/material.dart';

class ChatFooter extends StatelessWidget {
  const ChatFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: IconButton(
                  onPressed: () {
                    // Handle emoji button press
                  },
                  icon: Icon(Icons.emoji_emotions_outlined),
                ),
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              // Handle send button press
            },
          ),
      ],
      ),
    );
  }
}