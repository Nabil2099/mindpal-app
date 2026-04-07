import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mindpal_app/features/insights/domain/models.dart';
import 'package:mindpal_app/theme.dart';

class HabitPieChart extends StatefulWidget {
  const HabitPieChart({required this.habits, super.key});

  final List<HabitStat> habits;

  @override
  State<HabitPieChart> createState() => _HabitPieChartState();
}

class _HabitPieChartState extends State<HabitPieChart> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  List<HabitStat> get habits => widget.habits;

  // Earthy color palette matching the mockup
  static const List<Color> _palette = [
    Color(0xFF8B7355), // Brown/Tan (Meditation)
    Color(0xFFB86E4B), // Terracotta/Orange (Journaling)
    Color(0xFF6B8E6B), // Sage Green (Exercise)
    Color(0xFFCCAA55), // Mustard/Gold (Reading)
    Color(0xFF9B8B7A), // Taupe
    Color(0xFFA67B5B), // Camel
    Color(0xFF7A9E7A), // Moss Green
    Color(0xFFD4A574), // Sand
  ];

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No habit data available yet')),
      );
    }

    final total = habits.fold<int>(0, (value, item) => value + item.count);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Find dominant habit (largest slice)
    int dominantIndex = 0;
    int maxCount = 0;
    for (int i = 0; i < habits.length; i++) {
      if (habits[i].count > maxCount) {
        maxCount = habits[i].count;
        dominantIndex = i;
      }
    }
    final dominantPct = total == 0 ? 0 : (habits[dominantIndex].count / total * 100).round();

    final cardBorder = Border.all(
      color: isDark
          ? MindPalColors.darkBorder
          : MindPalColors.clay200.withValues(alpha: 0.7),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Habit Distribution Card - Expandable
        GestureDetector(
          onTap: _toggleExpand,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? MindPalColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: cardBorder,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with expand indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Habit Distribution',
                            style: GoogleFonts.fraunces(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: isDark ? MindPalColors.darkTextPrimary : MindPalColors.ink900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your practice breakdown this period',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: isDark ? MindPalColors.darkTextSecondary : MindPalColors.ink700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RotationTransition(
                      turns: Tween(begin: 0.0, end: 0.5).animate(_expandAnimation),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDark ? MindPalColors.darkTextSecondary : MindPalColors.ink700,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Chart centered
                Center(
                  child: SizedBox(
                    width: 160,
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 160 * 0.29,
                            sections: habits.asMap().entries.map((entry) {
                              final i = entry.key;
                              final item = entry.value;
                              final value = total == 0 ? 0.0 : item.count / total * 100;
                              return PieChartSectionData(
                                color: _palette[i % _palette.length],
                                value: value,
                                title: '',
                                radius: 160 * 0.21,
                                showTitle: false,
                              );
                            }).toList(growable: false),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$dominantPct%',
                              style: GoogleFonts.fraunces(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: isDark ? MindPalColors.darkTextPrimary : MindPalColors.ink900,
                              ),
                            ),
                            Text(
                              'DOMINANT',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: isDark ? MindPalColors.darkTextSecondary : MindPalColors.ink700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Animated legend section
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  axisAlignment: -1.0,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Divider
                      Container(
                        height: 1,
                        color: isDark
                            ? MindPalColors.darkBorder.withValues(alpha: 0.5)
                            : MindPalColors.clay200.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      // Legend items
                      _buildLegendGrid(context, habits, total, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Weekly Trend Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? MindPalColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: cardBorder,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Trend',
                style: GoogleFonts.fraunces(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: isDark ? MindPalColors.darkTextPrimary : MindPalColors.ink900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your habit consistency over the week',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: isDark ? MindPalColors.darkTextSecondary : MindPalColors.ink700,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: _WeeklyTrendChart(isDark: isDark),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendGrid(BuildContext context, List<HabitStat> habits, int total, bool isDark) {
    final legendItems = habits.asMap().entries.map((entry) {
      final i = entry.key;
      final item = entry.value;
      final pct = total == 0 ? 0 : (item.count / total * 100).round();
      return _LegendGridItem(
        color: _palette[i % _palette.length],
        label: _capitalize(item.name),
        percentage: pct,
        isDark: isDark,
      );
    }).toList();

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: legendItems.map((item) => SizedBox(
        width: (MediaQuery.of(context).size.width - 80) / 2, // ~half card width
        child: item,
      )).toList(),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}

class _LegendGridItem extends StatelessWidget {
  const _LegendGridItem({
    required this.color,
    required this.label,
    required this.percentage,
    required this.isDark,
  });

  final Color color;
  final String label;
  final int percentage;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? MindPalColors.darkTextPrimary
                      : MindPalColors.ink900,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                '$percentage%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? MindPalColors.darkTextSecondary.withValues(alpha: 0.6)
                      : MindPalColors.ink700.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeeklyTrendChart extends StatelessWidget {
  const _WeeklyTrendChart({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final lineColor = isDark ? MindPalColors.clay300 : MindPalColors.clay400;
    final gridColor = isDark ? MindPalColors.darkBorder : MindPalColors.clay100;
    final textColor = isDark ? MindPalColors.darkTextSecondary : MindPalColors.ink700;
    final tooltipBgColor = isDark ? MindPalColors.darkSurfaceHigh : MindPalColors.clay200;
    final tooltipTextColor = isDark ? MindPalColors.darkTextPrimary : MindPalColors.ink900;
    final inactiveDotColor = isDark ? MindPalColors.darkBorder : MindPalColors.clay300;

    // Sample data - this would come from actual habit tracking
    final spots = [
      const FlSpot(0, 25),  // Mon
      const FlSpot(1, 38),  // Tue
      const FlSpot(2, 45),  // Wed
      const FlSpot(3, 50),  // Thu
      const FlSpot(4, 68),  // Fri
      const FlSpot(5, 75),  // Sat
      const FlSpot(6, 92),  // Sun
    ];

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: gridColor,
              strokeWidth: 0.5,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                final index = value.toInt();
                if (index >= 0 && index < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      days[index],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 25,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 100,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => tooltipBgColor,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toInt()}%',
                  GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: tooltipTextColor,
                  ),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
          getTouchedSpotIndicator: (barData, spotIndexes) {
            return spotIndexes.map((index) {
              return TouchedSpotIndicatorData(
                const FlLine(color: Colors.transparent), // No vertical line
                FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, idx) {
                    return FlDotCirclePainter(
                      radius: 5,
                      color: lineColor,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
              );
            }).toList();
          },
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: lineColor,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: inactiveDotColor,
                  strokeWidth: 0,
                );
              },
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}
