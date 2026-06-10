import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/step_provider.dart';

class StepHistoryScreen extends StatefulWidget {
  const StepHistoryScreen({super.key});

  @override
  State<StepHistoryScreen> createState() => _StepHistoryScreenState();
}

class _StepHistoryScreenState extends State<StepHistoryScreen> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    _month = DateTime.now();
  }

  void _prevMonth() => setState(() => _month = DateTime(_month.year, _month.month - 1));
  void _nextMonth() {
    final now = DateTime.now();
    final next = DateTime(_month.year, _month.month + 1);
    if (next.year < now.year || (next.year == now.year && next.month <= now.month)) {
      setState(() => _month = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final provider = context.watch<StepProvider>();
    final locale = Localizations.localeOf(context).languageCode;
    final monthLabel = DateFormat('MMMM yyyy', locale).format(_month);
    final days = daysInMonth(_month);
    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday;
    final fmt = NumberFormat.decimalPattern();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Text(AppStrings.t(context, 'history'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: colors.cardDecoration(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left)),
                    Text(monthLabel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    AppStrings.t(context, 'mon'),
                    AppStrings.t(context, 'tue'),
                    AppStrings.t(context, 'wed'),
                    AppStrings.t(context, 'thu'),
                    AppStrings.t(context, 'fri'),
                    AppStrings.t(context, 'sat'),
                    AppStrings.t(context, 'sun'),
                  ].map((d) {
                    return Expanded(
                      child: Center(
                        child: Text(d, style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemCount: firstWeekday - 1 + days,
                  itemBuilder: (context, index) {
                    if (index < firstWeekday - 1) return const SizedBox();
                    final day = index - (firstWeekday - 1) + 1;
                    final date = DateTime(_month.year, _month.month, day);
                    final steps = provider.stepsForDay(date);
                    final ratio = provider.goal == 0 ? 0.0 : steps / provider.goal;
                    final isToday = isSameDay(date, DateTime.now());
                    final isFuture = date.isAfter(DateTime.now());

                    return Container(
                      decoration: BoxDecoration(
                        color: isFuture
                            ? Colors.transparent
                            : steps == 0
                                ? colors.surfaceVariant.withValues(alpha: 0.5)
                                : AppColors.progressColor(ratio.clamp(0.0, 1.0)).withValues(alpha: isDark(context) ? 0.25 + ratio * 0.45 : 0.15 + ratio * 0.35),
                        borderRadius: BorderRadius.circular(10),
                        border: isToday ? Border.all(color: colors.primary, width: 2) : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                              color: isFuture ? colors.onSurfaceVariant.withValues(alpha: 0.4) : colors.onSurface,
                            ),
                          ),
                          if (!isFuture && steps > 0)
                            Text(
                              steps >= 1000 ? '${(steps / 1000).toStringAsFixed(1)}k' : '$steps',
                              style: TextStyle(fontSize: 8, color: colors.onSurfaceVariant),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(AppStrings.t(context, 'monthlyOverview'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          ...List.generate(days, (i) {
            final day = DateTime(_month.year, _month.month, i + 1);
            if (day.isAfter(DateTime.now())) return const SizedBox();
            final steps = provider.stepsForDay(day);
            if (steps == 0) return const SizedBox();
            final dateLabel = DateFormat('dd/MM', locale).format(day);
            final ratio = provider.goal == 0 ? 0.0 : (steps / provider.goal).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: colors.cardBorder != null ? Border.all(color: colors.cardBorder!) : null,
              ),
              child: Row(
                children: [
                  Text(dateLabel, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 8,
                        backgroundColor: colors.surfaceVariant,
                        color: AppColors.progressColor(ratio),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(fmt.format(steps), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
}
