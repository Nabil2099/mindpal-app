import 'package:flutter/material.dart';

import 'package:mindpal_app/theme.dart';

class ChatInput extends StatelessWidget {
  const ChatInput({
    required this.controller,
    required this.onSend,
    super.key,
    this.docked = false,
    this.enabled = true,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool docked;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (docked)
              Container(
                margin: const EdgeInsets.only(right: 8, bottom: 4),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: MindPalColors.clay200),
                ),
                child: IconButton(
                  onPressed: enabled ? () {} : null,
                  icon: const Icon(Icons.today_outlined, size: 18),
                ),
              ),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 6,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Speak your heart...',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: MindPalColors.ink900,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: enabled ? onSend : null,
                color: Colors.white,
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
            ),
          ],
        ),
        if (docked)
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 8, 2, 0),
            child: Row(
              children: [
                Icon(
                  Icons.mic_none_rounded,
                  size: 18,
                  color: MindPalColors.ink700,
                ),
                SizedBox(width: 10),
                Icon(
                  Icons.image_outlined,
                  size: 18,
                  color: MindPalColors.ink700,
                ),
                Spacer(),
                Text(
                  'MINDPAL AI',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    color: MindPalColors.ink700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
