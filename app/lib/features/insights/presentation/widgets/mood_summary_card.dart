import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mindpal_app/features/insights/domain/models.dart';
import 'package:mindpal_app/theme.dart';

class MoodSummaryCard extends StatelessWidget {
  const MoodSummaryCard({required this.summary, super.key});

  final InsightsSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MindPalColors.clay100.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TODAY'S RESONANCE",
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 10),
          Text(
            'Your heart feels ${summary.mood.toLowerCase()} today.',
            style: GoogleFonts.newsreader(
              fontSize: 33,
              color: MindPalColors.ink900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text('Based on ${summary.entries} insight entries'),
          if (summary.dominantEmotion != null) ...[
            const SizedBox(height: 10),
            Text(
              summary.dominantEmotion!.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: MindPalColors.ink700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
