import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mindpal_app/features/chat/domain/models.dart';
import 'package:mindpal_app/theme.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({required this.message, super.key});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 290),
      decoration: BoxDecoration(
        color: isUser ? MindPalColors.clay200 : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isUser ? 20 : 6),
          bottomRight: Radius.circular(isUser ? 6 : 20),
        ),
        border: isUser ? null : Border.all(color: MindPalColors.clay200),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.text,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: MindPalColors.ink900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat('h:mm a').format(message.createdAt),
            style: const TextStyle(
              fontSize: 11,
              color: MindPalColors.ink700,
            ).copyWith(color: MindPalColors.ink700.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );

    if (isUser) {
      return Align(alignment: Alignment.centerRight, child: bubble);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: MindPalColors.sand100,
              shape: BoxShape.circle,
            ),
            child: const Text(
              'MP',
              style: TextStyle(
                color: MindPalColors.ink700,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(child: bubble),
        ],
      ),
    );
  }
}
