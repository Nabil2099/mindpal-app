import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mindpal_app/features/insights/data/insights_repository.dart';
import 'package:mindpal_app/features/insights/domain/models.dart';

part 'insights_providers.g.dart';

class InsightsState {
  const InsightsState({
    required this.emotions,
    required this.habits,
    required this.summary,
    required this.time,
    required this.selectedDay,
    required this.loading,
    this.error,
  });

  factory InsightsState.initial() => InsightsState(
    emotions: const <EmotionStat>[],
    habits: const <HabitStat>[],
    summary: const InsightsSummary(mood: 'Balanced', entries: 0, streak: 0),
    time: const <TimeInsight>[],
    selectedDay: 0,
    loading: true,
  );

  final List<EmotionStat> emotions;
  final List<HabitStat> habits;
  final InsightsSummary summary;
  final List<TimeInsight> time;
  final int selectedDay;
  final bool loading;
  final String? error;

  TimeInsight? get selectedTimeInsight {
    if (time.isEmpty) {
      return null;
    }
    return time[selectedDay.clamp(0, time.length - 1)];
  }

  InsightsState copyWith({
    List<EmotionStat>? emotions,
    List<HabitStat>? habits,
    InsightsSummary? summary,
    List<TimeInsight>? time,
    int? selectedDay,
    bool? loading,
    String? error,
  }) {
    return InsightsState(
      emotions: emotions ?? this.emotions,
      habits: habits ?? this.habits,
      summary: summary ?? this.summary,
      time: time ?? this.time,
      selectedDay: selectedDay ?? this.selectedDay,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

@riverpod
class InsightsNotifier extends _$InsightsNotifier {
  @override
  InsightsState build() {
    Future<void>.microtask(fetchInsights);
    return InsightsState.initial();
  }

  Future<void> fetchInsights() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final bundle = await ref.read(insightsRepositoryProvider).fetchAll();
      state = state.copyWith(
        emotions: bundle.emotions,
        habits: bundle.habits,
        summary: bundle.summary,
        time: bundle.time,
        selectedDay: 0,
        loading: false,
      );
    } catch (_) {
      state = state.copyWith(
        loading: false,
        error: 'Could not load insights right now.',
      );
    }
  }

  void selectPrevDay() {
    state = state.copyWith(selectedDay: (state.selectedDay - 1).clamp(0, 999));
  }

  void selectNextDay() {
    final max = state.time.isEmpty ? 0 : state.time.length - 1;
    state = state.copyWith(selectedDay: (state.selectedDay + 1).clamp(0, max));
  }
}
