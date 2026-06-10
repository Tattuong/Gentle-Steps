import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/step_constants.dart';
import '../../providers/locale_provider.dart';
import '../../providers/step_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_divider.dart';
import '../privacy_policy_screen.dart';
import '../reminders/step_reminders_screen.dart';

class StepSettingsScreen extends StatefulWidget {
  const StepSettingsScreen({super.key});

  @override
  State<StepSettingsScreen> createState() => _StepSettingsScreenState();
}

class _StepSettingsScreenState extends State<StepSettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = info.version);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final stepProvider = context.watch<StepProvider>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Text(AppStrings.t(context, 'settings'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          _Section(
            title: AppStrings.t(context, 'stepGoal'),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: StepConstants.goalOptions.map((g) {
                final selected = stepProvider.goal == g;
                return ChoiceChip(
                  label: Text('${g ~/ 1000}k'),
                  selected: selected,
                  onSelected: (_) => stepProvider.setGoal(g),
                  selectedColor: colors.primary.withValues(alpha: 0.2),
                  backgroundColor: colors.surfaceVariant,
                  labelStyle: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? colors.primary : colors.onSurface,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: AppStrings.t(context, 'theme'),
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(value: ThemeMode.light, label: Text(AppStrings.t(context, 'light'))),
                ButtonSegment(value: ThemeMode.dark, label: Text(AppStrings.t(context, 'dark'))),
              ],
              selected: {themeProvider.themeMode},
              onSelectionChanged: (s) => themeProvider.setThemeMode(s.first),
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: AppStrings.t(context, 'language'),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'en', label: Text(AppStrings.t(context, 'english'))),
                ButtonSegment(value: 'vi', label: Text(AppStrings.t(context, 'vietnamese'))),
              ],
              selected: {localeProvider.locale.languageCode},
              onSelectionChanged: (s) => localeProvider.setLocale(Locale(s.first)),
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.notifications_outlined, color: colors.primary),
              ),
              title: Text(AppStrings.t(context, 'reminders'), style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                stepProvider.reminderEnabled
                    ? AppStrings.t(context, 'everyHours', params: {'h': '${stepProvider.reminderIntervalHours}'})
                    : AppStrings.t(context, 'enableReminder'),
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StepRemindersScreen())),
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: AppStrings.t(context, 'widget'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.t(context, 'widgetDesc'), style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.widgets_outlined, color: colors.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppStrings.t(context, 'widgetHint'),
                          style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: AppStrings.t(context, 'about'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.t(context, 'aboutDesc'), style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14, height: 1.5)),
                const SizedBox(height: 12),
                if (_version.isNotEmpty)
                  Text('${AppStrings.t(context, 'version')}: $_version', style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
                const SizedBox(height: 8),
                Text(AppStrings.t(context, 'copyright'), style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(AppStrings.t(context, 'privacyPolicy'), style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String? title;
  final Widget child;

  const _Section({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: colors.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const AppDivider(),
          ],
          child,
        ],
      ),
    );
  }
}
