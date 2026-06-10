import 'package:flutter/material.dart';

import '../widgets/app_bottom_nav.dart';
import 'history/step_history_screen.dart';
import 'home/step_home_screen.dart';
import 'settings/step_settings_screen.dart';
import 'stats/step_stats_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [
    StepHomeScreen(),
    StepStatsScreen(),
    StepHistoryScreen(),
    StepSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
