import 'package:flutter/material.dart';

class ChatContent extends StatelessWidget {
  const ChatContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(16.0)  ,
        child: ListView(
          children: [
            ItemChat(isSender: true, message: 'Hallo, aku Faradis Yulianto!', time: '18:22 PM'),
            ItemChat(isSender: false, message: 'Hallo Faradis, kenalin aku Anton!', time: '18:24 PM'),
          ],
        ),
      ),
    );
  }
}

class ItemChat extends StatelessWidget {
  const ItemChat({
    super.key,
    required this.isSender,
    required this.message,
    required this.time,
  });

  final bool isSender;
  final String message;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(isSender ? 15 : 0),
                bottomRight: Radius.circular(isSender ? 0 : 15),
              ),
              color: Colors.grey[300],
            ),
            child: Text(message),
          ),
          Text(time),
        ],
      ),
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
    );
  }
}
