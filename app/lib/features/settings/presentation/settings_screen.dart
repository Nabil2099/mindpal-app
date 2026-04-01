import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mindpal_app/shared/providers/local_cache_provider.dart';
import 'package:mindpal_app/shared/widgets/mindpal_card.dart';
import 'package:mindpal_app/shared/widgets/pill_button.dart';
import 'package:mindpal_app/theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _clearCache(BuildContext context, WidgetRef ref) async {
    await ref.read(localCacheServiceProvider).clearAll();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Local cache cleared.')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.newsreader(
            fontSize: 32,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [MindPalColors.surface, MindPalColors.surfaceLow],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'SETTINGS',
              style: textTheme.labelSmall?.copyWith(
                color: MindPalColors.clay400,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tune your quiet space',
              style: GoogleFonts.newsreader(fontSize: 40, height: 1.05),
            ),
            const SizedBox(height: 18),
            MindPalCard(
              color: MindPalColors.surfaceLow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Profile', style: textTheme.titleLarge),
                  const SizedBox(height: 10),
                  const _SettingsRow(
                    icon: Icons.person_outline,
                    label: 'Name',
                    trailing: 'MindPal User',
                  ),
                  const Divider(height: 20),
                  const _SettingsRow(
                    icon: Icons.favorite_border,
                    label: 'Wellness goal',
                    trailing: 'Emotional balance',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            MindPalCard(
              color: MindPalColors.surfaceLow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reminders', style: textTheme.titleLarge),
                  const SizedBox(height: 10),
                  const _SwitchRow(
                    icon: Icons.notifications_none,
                    label: 'Daily reflection prompt',
                    value: true,
                  ),
                  const Divider(height: 20),
                  const _SwitchRow(
                    icon: Icons.nights_stay_outlined,
                    label: 'Evening wind-down reminder',
                    value: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            MindPalCard(
              color: MindPalColors.surfaceLow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Storage & privacy', style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text(
                    'Clear local cache if you want to reset offline context and local snapshots.',
                  ),
                  const SizedBox(height: 14),
                  PillButton(
                    label: 'Clear cache',
                    variant: PillButtonVariant.ghost,
                    onPressed: () => _clearCache(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            MindPalCard(
              color: MindPalColors.surfaceLow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About MindPal', style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text('Version 1.0.0'),
                  const SizedBox(height: 8),
                  const Text(
                    'MindPal is a reflective AI companion for emotional wellness and gentle daily rituals.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  final IconData icon;
  final String label;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: MindPalColors.ink700),
        const SizedBox(width: 10),
        Expanded(child: Text(label)),
        Text(trailing, style: const TextStyle(color: MindPalColors.ink700)),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: MindPalColors.ink700),
        const SizedBox(width: 10),
        Expanded(child: Text(label)),
        Switch.adaptive(
          value: value,
          onChanged: (_) {},
          activeThumbColor: MindPalColors.ink900,
        ),
      ],
    );
  }
}
