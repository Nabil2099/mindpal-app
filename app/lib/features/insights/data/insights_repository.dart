import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mindpal_app/constants.dart';
import 'package:mindpal_app/features/insights/domain/models.dart';
import 'package:mindpal_app/shared/providers/core_providers.dart';

part 'insights_repository.g.dart';

class InsightsBundle {
  const InsightsBundle({
    required this.emotions,
    required this.habits,
    required this.summary,
    required this.time,
  });

  final List<EmotionStat> emotions;
  final List<HabitStat> habits;
  final InsightsSummary summary;
  final List<TimeInsight> time;
}

class InsightsRepository {
  InsightsRepository(this._dio);

  final Dio _dio;

  Future<InsightsBundle> fetchAll() async {
    final query = <String, Object?>{'user_id': kUserId};
    final responses = await Future.wait([
      _dio.get<List<dynamic>>('/insights/emotions', queryParameters: query),
      _dio.get<List<dynamic>>('/insights/habits', queryParameters: query),
      _dio.get<Map<String, dynamic>>(
        '/insights/summary',
        queryParameters: query,
      ),
      _dio.get<List<dynamic>>('/insights/time', queryParameters: query),
    ]);

    final emotionsData =
        responses[0].data as List<dynamic>? ?? const <dynamic>[];
    final habitsData = responses[1].data as List<dynamic>? ?? const <dynamic>[];
    final summaryData =
        responses[2].data as Map<String, dynamic>? ?? const <String, dynamic>{};
    final timeData = responses[3].data as List<dynamic>? ?? const <dynamic>[];
    final totalMessages = timeData
        .whereType<Map<String, dynamic>>()
        .map((item) => (item['message_count'] as num?)?.toDouble() ?? 0)
        .fold<double>(0, (a, b) => a + b);

    return InsightsBundle(
      emotions: emotionsData
          .whereType<Map<String, dynamic>>()
          .map(EmotionStat.fromJson)
          .toList(growable: false),
      habits: habitsData
          .whereType<Map<String, dynamic>>()
          .map(HabitStat.fromJson)
          .toList(growable: false),
      summary: InsightsSummary.fromJson(summaryData),
      time: timeData
          .whereType<Map<String, dynamic>>()
          .map((item) {
            final next = Map<String, dynamic>.from(item);
            final count = (item['message_count'] as num?)?.toDouble() ?? 0;
            final normalized =
                totalMessages == 0 ? 0.0 : (count / totalMessages) * 100;
            next['message_count'] = normalized;
            return TimeInsight.fromJson(next);
          })
          .toList(growable: false),
    );
  }
}

@riverpod
InsightsRepository insightsRepository(Ref ref) {
  return InsightsRepository(ref.watch(dioProvider));
}
