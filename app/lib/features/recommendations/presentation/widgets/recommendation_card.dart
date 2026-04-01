import 'package:flutter/material.dart';

import 'package:mindpal_app/features/recommendations/domain/models.dart';
import 'package:mindpal_app/shared/widgets/pill_button.dart';
import 'package:mindpal_app/theme.dart';

class RecommendationCard extends StatefulWidget {
  const RecommendationCard({required this.item, super.key});

  final RecommendationItem item;

  @override
  State<RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<RecommendationCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MindPalColors.surfaceLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _TinyPill(label: item.kind.toUpperCase(), bg: Colors.white),
                    _TinyPill(
                      label: item.duration.toUpperCase(),
                      bg: MindPalColors.clay100,
                    ),
                    _TinyPill(
                      label: item.status.toUpperCase(),
                      bg: MindPalColors.clay200,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: MindPalColors.ink900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.rationale,
                  maxLines: _expanded ? null : 2,
                  overflow:
                      _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: MindPalColors.ink700,
                  ),
                ),
                if (_expanded && item.followUp != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: MindPalColors.clay200),
                    ),
                    child: Text(item.followUp!),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Column(
              children: [
                const PillButton(
                  label: 'Start',
                  onPressed: null,
                  expanded: true,
                ),
                const SizedBox(height: 6),
                PillButton(
                  label: _expanded ? 'Hide details' : 'Show details',
                  variant: PillButtonVariant.secondary,
                  expanded: true,
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
                const SizedBox(height: 6),
                const PillButton(
                  label: 'More',
                  variant: PillButtonVariant.secondary,
                  expanded: true,
                  onPressed: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyPill extends StatelessWidget {
  const _TinyPill({required this.label, required this.bg});

  final String label;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: MindPalColors.ink800,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
