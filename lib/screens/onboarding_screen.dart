import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/services/step_service.dart';
import '../core/services/storage_service.dart';
import '../widgets/app_logo.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _finish(BuildContext context) async {
    await StepService.instance.requestPermission();
    await StorageService.instance.saveBool('onboarding_done', true);
    if (context.mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final features = [
      ('👟', AppStrings.t(context, 'onboardingFeature1')),
      ('📊', AppStrings.t(context, 'onboardingFeature2')),
      ('📱', AppStrings.t(context, 'onboardingFeature3')),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.softGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                const AppLogo(size: 120),
                const SizedBox(height: 32),
                Text(
                  AppStrings.t(context, 'onboardingTitle'),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.t(context, 'onboardingSubtitle'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 36),
                ...features.map(
                  (f) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text(f.$1, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 14),
                        Expanded(child: Text(f.$2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _finish(context),
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: Text(AppStrings.t(context, 'start')),
                  ),
                ),
                TextButton(
                  onPressed: () => _finish(context),
                  child: Text(AppStrings.t(context, 'skip'), style: const TextStyle(color: AppColors.onSurfaceVariant)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
