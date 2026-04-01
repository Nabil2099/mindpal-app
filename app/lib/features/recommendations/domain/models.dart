class RecommendationItem {
  const RecommendationItem({
    required this.id,
    required this.title,
    required this.rationale,
    required this.kind,
    required this.duration,
    required this.status,
    this.followUp,
  });

  final String id;
  final String title;
  final String rationale;
  final String kind;
  final String duration;
  final String status;
  final String? followUp;

  factory RecommendationItem.fromJson(Map<String, dynamic> json) {
    final minutes = (json['estimated_duration_minutes'] as num?)?.toInt();
    return RecommendationItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Recommendation',
      rationale: json['rationale']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'Mindset',
      duration:
          json['duration']?.toString() ??
          (minutes == null ? '5m' : '${minutes}m'),
      status: json['status']?.toString() ?? 'new',
      followUp:
          json['follow_up']?.toString() ?? json['follow_up_text']?.toString(),
    );
  }
}

class HabitChecklistItem {
  const HabitChecklistItem({
    required this.id,
    required this.name,
    required this.completed,
  });

  final String id;
  final String name;
  final bool completed;

  factory HabitChecklistItem.fromJson(Map<String, dynamic> json) {
    final habit = json['habit'] as Map<String, dynamic>?;
    return HabitChecklistItem(
      id: json['id']?.toString() ?? habit?['id']?.toString() ?? '',
      name: json['name']?.toString() ?? habit?['name']?.toString() ?? 'Habit',
      completed:
          json['completed'] as bool? ?? json['is_completed'] as bool? ?? false,
    );
  }

  HabitChecklistItem copyWith({String? id, String? name, bool? completed}) {
    return HabitChecklistItem(
      id: id ?? this.id,
      name: name ?? this.name,
      completed: completed ?? this.completed,
    );
  }
}
