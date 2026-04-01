import 'package:flutter/material.dart';

import 'package:mindpal_app/features/insights/domain/models.dart';
import 'package:mindpal_app/theme.dart';

class EmotionBarChart extends StatelessWidget {
  const EmotionBarChart({required this.items, super.key});

  final List<EmotionStat> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('No data available yet')),
      );
    }

    final maxCount = items
        .map((e) => e.count)
        .fold<int>(1, (a, b) => a > b ? a : b);

    return SizedBox(
      height: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: items
            .map(
              (item) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('${item.count}'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 176,
                        decoration: BoxDecoration(
                          color: MindPalColors.sand50,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 450),
                          width: double.infinity,
                          height: 176 * (item.count / maxCount),
                          decoration: BoxDecoration(
                            color: MindPalColors.emotionColor(item.label),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.label.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          color: MindPalColors.ink700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}
