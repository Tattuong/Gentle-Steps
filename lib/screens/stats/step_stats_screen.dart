import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../providers/step_provider.dart';
import '../../widgets/step_stat_card.dart';
import '../../widgets/step_week_chart.dart';

class StepStatsScreen extends StatelessWidget {
  const StepStatsScreen({super.key});

  List<String> _dayLabels(BuildContext context) => [
        AppStrings.t(context, 'mon'),
        AppStrings.t(context, 'tue'),
        AppStrings.t(context, 'wed'),
        AppStrings.t(context, 'thu'),
        AppStrings.t(context, 'fri'),
        AppStrings.t(context, 'sat'),
        AppStrings.t(context, 'sun'),
      ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StepProvider>();
    final fmt = NumberFormat.decimalPattern();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Text(AppStrings.t(context, 'stats'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: StepStatCard(
                  icon: '📊',
                  label: AppStrings.t(context, 'average'),
                  value: fmt.format(provider.weeklyAverage.round()),
                  suffix: AppStrings.t(context, 'perDay'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StepStatCard(
                  icon: '🔥',
                  label: AppStrings.t(context, 'streak'),
                  value: '${provider.streakDays}',
                  suffix: AppStrings.t(context, 'days'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StepStatCard(
                  icon: '👟',
                  label: AppStrings.t(context, 'totalSteps'),
                  value: fmt.format(provider.weeklyTotal),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StepStatCard(
                  icon: '🏆',
                  label: AppStrings.t(context, 'bestDay'),
                  value: fmt.format(provider.bestDaySteps),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          StepWeekChart(
            steps: provider.weeklySteps(),
            dayLabels: _dayLabels(context),
            goal: provider.goal,
          ),
        ],
      ),
    );
  }
}
