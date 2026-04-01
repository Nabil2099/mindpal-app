import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:mindpal_app/features/insights/domain/models.dart';
import 'package:mindpal_app/theme.dart';

class HabitPieChart extends StatelessWidget {
  const HabitPieChart({required this.habits, super.key});

  final List<HabitStat> habits;

  @override
  Widget build(BuildContext context) {
    final total = habits.fold<int>(0, (value, item) => value + item.count);
    final palette = <Color>[
      MindPalColors.clay300,
      MindPalColors.emotionJoy,
      MindPalColors.emotionCalm,
      MindPalColors.emotionExcitement,
      MindPalColors.emotionGratitude,
    ];

    return Row(
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 24,
              sections: habits
                  .asMap()
                  .entries
                  .map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    final value = total == 0 ? 0.0 : item.count / total * 100;
                    return PieChartSectionData(
                      color: palette[i % palette.length],
                      value: value,
                      title: '${value.round()}%',
                      radius: 42,
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: habits
                .asMap()
                .entries
                .map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  final pct =
                      total == 0 ? 0 : (item.count / total * 100).round();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: MindPalColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: palette[i % palette.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item.name)),
                        Text('$pct%'),
                      ],
                    ),
                  );
                })
                .toList(growable: false),
          ),
        ),
      ],
    );
  }
}
