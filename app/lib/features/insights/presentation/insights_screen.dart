import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:mindpal_app/features/insights/providers/insights_providers.dart';
import 'package:mindpal_app/features/insights/presentation/widgets/day_emotion_widget.dart';
import 'package:mindpal_app/features/insights/presentation/widgets/emotion_bar_chart.dart';
import 'package:mindpal_app/features/insights/presentation/widgets/habit_pie_chart.dart';
import 'package:mindpal_app/features/insights/presentation/widgets/mood_summary_card.dart';
import 'package:mindpal_app/features/insights/presentation/widgets/streak_card.dart';
import 'package:mindpal_app/shared/widgets/mindpal_card.dart';
import 'package:mindpal_app/shared/widgets/shimmer_loader.dart';
import 'package:mindpal_app/shared/widgets/state_panels.dart';
import 'package:mindpal_app/theme.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(insightsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Emotional Patterns',
          style: GoogleFonts.newsreader(
            fontSize: 32,
            fontWeight: FontWeight.w600,
          ),
        ),
        toolbarHeight: 78,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'A curated view of your internal landscape.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: MindPalColors.ink700),
            ),
          ),
        ),
      ),
      body:
          state.loading
              ? const _LoadingBody()
              : state.error != null
              ? _ErrorBody(
                message: state.error!,
                onRetry: ref.read(insightsProvider.notifier).fetchInsights,
              )
              : state.emotions.isEmpty &&
                  state.habits.isEmpty &&
                  state.time.isEmpty
              ? MindPalEmptyPanel(
                title: 'No insights yet',
                subtitle:
                    'Start a few chats and reflections to reveal your emotional landscape.',
                actionLabel: 'Refresh insights',
                icon: Icons.query_stats,
                onAction: ref.read(insightsProvider.notifier).fetchInsights,
              )
              : RefreshIndicator(
                onRefresh:
                    () => ref.read(insightsProvider.notifier).fetchInsights(),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [MindPalColors.surface, MindPalColors.surfaceLow],
                    ),
                  ),
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        sliver: SliverList.list(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                children: [
                                  _DayButton(
                                    icon: Icons.chevron_left,
                                    onTap:
                                        ref
                                            .read(insightsProvider.notifier)
                                            .selectPrevDay,
                                  ),
                                  const Spacer(),
                                  Column(
                                    children: [
                                      Text(
                                        DateFormat('EEEE').format(
                                          state.selectedTimeInsight?.date ??
                                              DateTime.now(),
                                        ),
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.labelSmall,
                                      ),
                                      Text(
                                        DateFormat('MMMM d').format(
                                          state.selectedTimeInsight?.date ??
                                              DateTime.now(),
                                        ),
                                        style: GoogleFonts.newsreader(
                                          fontSize: 22,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  _DayButton(
                                    icon: Icons.chevron_right,
                                    onTap:
                                        ref
                                            .read(insightsProvider.notifier)
                                            .selectNextDay,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            MindPalCard(
                              radius: 28,
                              color: MindPalColors.surfaceLow,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Emotion Frequency',
                                    style: GoogleFonts.newsreader(fontSize: 27),
                                  ),
                                  const SizedBox(height: 16),
                                  EmotionBarChart(items: state.emotions),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final wide = constraints.maxWidth >= 640;
                                if (!wide) {
                                  return Column(
                                    children: [
                                      MoodSummaryCard(summary: state.summary),
                                      const SizedBox(height: 12),
                                      StreakCard(streak: state.summary.streak),
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    Expanded(
                                      child: MoodSummaryCard(
                                        summary: state.summary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: StreakCard(
                                        streak: state.summary.streak,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            MindPalCard(
                              radius: 28,
                              color: MindPalColors.surfaceLow,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Habit Frequency',
                                    style: GoogleFonts.newsreader(fontSize: 27),
                                  ),
                                  const SizedBox(height: 12),
                                  HabitPieChart(habits: state.habits),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            MindPalCard(
                              radius: 28,
                              color: MindPalColors.surfaceLow,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Time Snapshot',
                                        style: GoogleFonts.newsreader(
                                          fontSize: 27,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (state.selectedTimeInsight != null)
                                    Text(
                                      DateFormat(
                                        'h a',
                                      ).format(state.selectedTimeInsight!.date),
                                    ),
                                  const SizedBox(height: 12),
                                  DayEmotionWidget(
                                    items:
                                        state.selectedTimeInsight?.items ??
                                        const [],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'The quiet mind is a vessel for self-discovery.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.newsreader(
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                                color: MindPalColors.ink700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

class _DayButton extends StatelessWidget {
  const _DayButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: MindPalColors.clay200),
          shape: const CircleBorder(),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: const [
          ShimmerLoader(width: double.infinity, height: 230, radius: 24),
          SizedBox(height: 20),
          ShimmerLoader(width: double.infinity, height: 150, radius: 20),
          SizedBox(height: 20),
          ShimmerLoader(width: double.infinity, height: 200, radius: 24),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MindPalErrorPanel(
      message: message,
      title: 'Could not load insights',
      onRetry: onRetry,
    );
  }
}
