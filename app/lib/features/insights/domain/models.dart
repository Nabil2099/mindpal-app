class EmotionStat {
  const EmotionStat({required this.label, required this.count});

  final String label;
  final int count;

  factory EmotionStat.fromJson(Map<String, dynamic> json) {
    return EmotionStat(
      label: json['label']?.toString() ?? 'Neutral',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class HabitStat {
  const HabitStat({required this.name, required this.count});

  final String name;
  final int count;

  factory HabitStat.fromJson(Map<String, dynamic> json) {
    return HabitStat(
      name: json['name']?.toString() ?? json['habit']?.toString() ?? 'Habit',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class InsightsSummary {
  const InsightsSummary({
    required this.mood,
    required this.entries,
    required this.streak,
    this.dominantEmotion,
  });

  final String mood;
  final int entries;
  final int streak;
  final String? dominantEmotion;

  factory InsightsSummary.fromJson(Map<String, dynamic> json) {
    final dominantEmotion = json['dominant_emotion']?.toString();
    return InsightsSummary(
      mood: json['mood']?.toString() ?? dominantEmotion ?? 'Balanced',
      entries:
          (json['entries'] as num?)?.toInt() ??
          (json['total_messages'] as num?)?.toInt() ??
          0,
      streak:
          (json['streak'] as num?)?.toInt() ??
          (json['active_days'] as num?)?.toInt() ??
          0,
      dominantEmotion: dominantEmotion,
    );
  }
}

class DayEmotion {
  const DayEmotion({required this.label, required this.percent});

  final String label;
  final double percent;

  factory DayEmotion.fromJson(Map<String, dynamic> json) {
    return DayEmotion(
      label: json['label']?.toString() ?? 'Neutral',
      percent: (json['percent'] as num?)?.toDouble() ?? 0,
    );
  }
}

class TimeInsight {
  const TimeInsight({required this.date, required this.items});

  final DateTime date;
  final List<DayEmotion> items;

  factory TimeInsight.fromJson(Map<String, dynamic> json) {
    final date = DateTime.tryParse(json['date']?.toString() ?? '');
    final raw = (json['emotions'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(DayEmotion.fromJson)
        .toList(growable: false);

    if (raw.isNotEmpty) {
      return TimeInsight(date: date ?? DateTime.now(), items: raw);
    }

    final hour = (json['hour_of_day'] as num?)?.toInt();
    final count = (json['message_count'] as num?)?.toDouble() ?? 0;
    final label = json['top_emotion']?.toString() ?? 'Neutral';

    return TimeInsight(
      date:
          hour == null
              ? (date ?? DateTime.now())
              : DateTime.now().copyWith(
                hour: hour,
                minute: 0,
                second: 0,
                millisecond: 0,
                microsecond: 0,
              ),
      items: <DayEmotion>[DayEmotion(label: label, percent: count)],
    );
  }
}
