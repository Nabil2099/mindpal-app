import 'package:flutter/material.dart';
import 'package:mindpal_app/theme.dart';

enum PillButtonVariant { primary, secondary, ghost }

class PillButton extends StatelessWidget {
  const PillButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = PillButtonVariant.primary,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final PillButtonVariant variant;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final style = _style();
    final child = FilledButton(
      onPressed: onPressed,
      style: style,
      child: Text(label),
    );

    if (!expanded) {
      return child;
    }
    return SizedBox(width: double.infinity, child: child);
  }

  ButtonStyle _style() {
    switch (variant) {
      case PillButtonVariant.primary:
        return FilledButton.styleFrom(
          backgroundColor: MindPalColors.ink900,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        );
      case PillButtonVariant.secondary:
        return FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: MindPalColors.ink800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: const BorderSide(color: MindPalColors.clay300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        );
      case PillButtonVariant.ghost:
        return FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: MindPalColors.ink700,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        );
    }
  }
}
