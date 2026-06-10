import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';

class StepWeekChart extends StatelessWidget {
  final List<int> steps;
  final List<String> dayLabels;
  final int goal;

  const StepWeekChart({
    super.key,
    required this.steps,
    required this.dayLabels,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final maxVal = steps.isEmpty ? goal.toDouble() : steps.reduce((a, b) => a > b ? a : b).toDouble();
    final maxY = (maxVal * 1.2).clamp(goal.toDouble(), goal * 1.5);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: colors.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.t(context, 'thisWeek'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.15),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, _) {
                        if (v == 0) return const SizedBox();
                        return Text(
                          _shortNum(v.toInt()),
                          style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= dayLabels.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            dayLabels[i],
                            style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(steps.length, (i) {
                  final count = steps[i];
                  final ratio = goal == 0 ? 0.0 : count / goal;
                  final color = count == 0
                      ? colors.onSurfaceVariant.withValues(alpha: 0.15)
                      : AppColors.progressColor(ratio.clamp(0.0, 1.0));
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: count == 0 ? maxY * 0.03 : count.toDouble(),
                        color: color,
                        width: 22,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ],
                  );
                }),
              ),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
            ),
          ),
        ],
      ),
    );
  }

  String _shortNum(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return NumberFormat.compact().format(n);
  }
}
