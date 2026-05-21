import 'dart:math';

import 'package:flutter/material.dart';

class ChatMessage {
  const ChatMessage({
    required this.isSender,
    required this.message,
    required this.time,
  });

  final bool isSender;
  final String message;
  final String time;
}

class ChatContent extends StatelessWidget {
  const ChatContent({super.key, this.messages});

  final List<ChatMessage>? messages;

  static const List<ChatMessage> _defaultMessages = [
    ChatMessage(
      isSender: false,
      message:
          'Halo, aku siap mendengarkanmu. Tidak perlu menahan semuanya sendiri. Apa yang sedang memenuhi pikiranmu hari ini?',
      time: '02:15',
    ),
    ChatMessage(
      isSender: true,
      message:
          'Aku sangat lelah hari ini, aku capek banget dari kemarin aku tidur subuh terus ngerjain proyek GDGOC sini',
      time: '02:16',
    ),
    ChatMessage(
      isSender: false,
      message:
          'Turut berduka ya.. Saranku sih gausah dikerjain yaa biar kamu bisa tidur cukup',
      time: '02:16',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final items = messages ?? _defaultMessages;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
        child: ListView.separated(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            return ItemChat(
              isSender: item.isSender,
              message: item.message,
              time: item.time,
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: items.length,
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
    final bubbleColor = isSender
        ? const Color(0xFFE3F1FF)
        : const Color(0xFF1E4E75);
    final textColor = isSender ? const Color(0xFF0A2A3F) : Colors.white;
    final timeColor = const Color(0xFF94A3B8);

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSender) ...[
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Tail di luar Stack, di kiri atas — pakai Positioned.fill agar Stack punya ukuran dari Container
                Container(
                  constraints: const BoxConstraints(maxWidth: 280),
                  // ← HAPUS margin top
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    12,
                    14,
                    12,
                  ), // ← tambah padding kiri untuk ruang tail
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(
                        0,
                      ), // ← pojok kiri atas rata (tail mengisi sini)
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: _buildMessageContent(textColor, message),
                ),
                Positioned(
                  left: -10, // ← geser ke kiri, keluar dari bubble
                  top: 0,
                  child: CustomPaint(
                    size: const Size(14, 14),
                    painter: _TailPainter(color: bubbleColor, isLeft: true),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: timeColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ] else ...[
            Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: timeColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 24),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 280),
                  // ← HAPUS margin top
                  padding: const EdgeInsets.fromLTRB(
                    14,
                    12,
                    20,
                    12,
                  ), // ← tambah padding kanan untuk ruang tail
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(0), // ← pojok kanan atas rata
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: _buildMessageContent(textColor, message),
                ),
                Positioned(
                  right: -10, // ← geser ke kanan, keluar dari bubble
                  top: 0,
                  child: CustomPaint(
                    size: const Size(14, 14),
                    painter: _TailPainter(color: bubbleColor, isLeft: false),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

Widget _buildMessageContent(Color textColor, String message) {
  return Text(
    message,
    style: TextStyle(color: textColor, height: 1.35, fontSize: 14),
  );
}

class _TailPainter extends CustomPainter {
  const _TailPainter({required this.color, required this.isLeft});

  final Color color;
  final bool isLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (isLeft) {
      // Tail di pojok kiri atas → lancip mengarah ke kiri-atas
      path.moveTo(0, 0); // ujung lancip (kiri atas)
      path.lineTo(size.width, 0); // kanan atas
      path.lineTo(size.width, size.height); // kanan bawah
      path.close();
    } else {
      // Tail di pojok kanan atas → lancip mengarah ke kanan-atas
      path.moveTo(size.width, 0); // ujung lancip (kanan atas)
      path.lineTo(0, 0); // kiri atas
      path.lineTo(0, size.height); // kiri bawah
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TailPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isLeft != isLeft;
}
