import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/notification_service.dart';
import '../../providers/step_provider.dart';

class StepRemindersScreen extends StatelessWidget {
  const StepRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StepProvider>();
    final scheduleHours = NotificationService.instance.scheduleHours(provider.reminderIntervalHours);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.t(context, 'reminders'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            title: Text(AppStrings.t(context, 'enableReminder'), style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(AppStrings.t(context, 'walkReminderBody'), style: const TextStyle(fontSize: 13)),
            value: provider.reminderEnabled,
            activeColor: AppColors.primary,
            onChanged: provider.setReminderEnabled,
          ),
          const SizedBox(height: 16),
          Text(AppStrings.t(context, 'reminderInterval'), style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [2, 3, 4, 6].map((h) {
              final selected = provider.reminderIntervalHours == h;
              return ChoiceChip(
                label: Text(AppStrings.t(context, 'everyHours', params: {'h': '$h'})),
                selected: selected,
                onSelected: provider.reminderEnabled ? (_) => provider.setReminderInterval(h) : null,
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
              );
            }).toList(),
          ),
          if (provider.reminderEnabled) ...[
            const SizedBox(height: 24),
            Text(AppStrings.t(context, 'reminderTimes'), style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...scheduleHours.map(
              (h) => ListTile(
                leading: const Icon(Icons.access_time, color: AppColors.primary),
                title: Text('${h.toString().padLeft(2, '0')}:00'),
                dense: true,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
