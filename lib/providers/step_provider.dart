import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';

import '../core/constants/app_strings.dart';
import '../core/constants/step_constants.dart';
import '../core/services/notification_service.dart';
import '../core/services/step_service.dart';
import '../core/services/storage_service.dart';
import '../core/services/widget_service.dart';
import '../core/utils/date_utils.dart';

class StepProvider extends ChangeNotifier {
  static const _historyKey = 'step_history';
  static const _goalKey = 'step_goal';
  static const _baselineKey = 'step_baseline';
  static const _baselineDateKey = 'step_baseline_date';
  static const _reminderEnabledKey = 'step_reminder_enabled';
  static const _reminderIntervalKey = 'step_reminder_interval';
  static const _goalNotifiedKey = 'step_goal_notified_date';

  int _todaySteps = 0;
  int _rawSteps = 0;
  int _baseline = 0;
  int _goal = StepConstants.defaultGoal;
  bool _sensorAvailable = true;
  bool _permissionGranted = true;
  bool _reminderEnabled = false;
  int _reminderIntervalHours = 3;
  String _pedestrianStatus = 'unknown';
  Map<String, int> _history = {};

  StreamSubscription<StepCount>? _stepSub;
  StreamSubscription<PedestrianStatus>? _statusSub;

  int get todaySteps => _todaySteps;
  int get goal => _goal;
  double get progress => _goal == 0 ? 0 : (_todaySteps / _goal).clamp(0.0, 1.0);
  bool get goalReached => _todaySteps >= _goal;
  bool get sensorAvailable => _sensorAvailable;
  bool get permissionGranted => _permissionGranted;
  bool get reminderEnabled => _reminderEnabled;
  int get reminderIntervalHours => _reminderIntervalHours;
  String get pedestrianStatus => _pedestrianStatus;

  double get distanceKm => (_todaySteps * StepConstants.avgStrideMeters) / 1000;
  double get calories => _todaySteps * StepConstants.caloriesPerStep;

  int get streakDays {
    var streak = 0;
    var day = DateTime.now();
    while (true) {
      final key = _dateKey(day);
      final steps = key == _dateKey(DateTime.now()) ? _todaySteps : (_history[key] ?? 0);
      if (steps >= _goal * 0.5) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int get weeklyTotal {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return stepsForDay(day);
    }).fold(0, (a, b) => a + b);
  }

  double get weeklyAverage => weeklyTotal / 7;

  int get bestDaySteps {
    final all = [..._history.values, _todaySteps];
    if (all.isEmpty) return 0;
    return all.reduce((a, b) => a > b ? a : b);
  }

  StepProvider() {
    _load();
  }

  Future<void> _load() async {
    _goal = await StorageService.instance.getInt(_goalKey) ?? StepConstants.defaultGoal;
    _reminderEnabled = await StorageService.instance.getBool(_reminderEnabledKey) ?? false;
    _reminderIntervalHours = await StorageService.instance.getInt(_reminderIntervalKey) ?? 3;

    final rawHistory = await StorageService.instance.getString(_historyKey);
    if (rawHistory != null) {
      final map = jsonDecode(rawHistory) as Map<String, dynamic>;
      _history = map.map((k, v) => MapEntry(k, v as int));
    }

    await _initBaseline();
    await _syncReminders();
    await _startListening();
    notifyListeners();
  }

  Future<void> _initBaseline() async {
    final today = _dateKey(DateTime.now());
    final savedDate = await StorageService.instance.getString(_baselineDateKey);
    _baseline = await StorageService.instance.getInt(_baselineKey) ?? 0;

    if (savedDate != today) {
      if (savedDate != null && _todaySteps > 0) {
        _history[savedDate] = _todaySteps;
        await _saveHistory();
      }
      _baseline = _rawSteps;
      await StorageService.instance.saveString(_baselineDateKey, today);
      await StorageService.instance.saveInt(_baselineKey, _baseline);
      await StorageService.instance.remove(_goalNotifiedKey);
    }
  }

  Future<void> _startListening() async {
    _permissionGranted = await StepService.instance.hasPermission();
    if (!_permissionGranted) {
      notifyListeners();
      return;
    }

    await _stepSub?.cancel();
    await _statusSub?.cancel();

    _stepSub = StepService.instance.stepStream.listen(
      _onStepCount,
      onError: (_) {
        _sensorAvailable = false;
        notifyListeners();
      },
    );

    _statusSub = StepService.instance.statusStream.listen(
      (status) {
        _pedestrianStatus = status.status;
        notifyListeners();
      },
      onError: (_) {},
    );
  }

  void _onStepCount(StepCount event) {
    _rawSteps = event.steps;
    _sensorAvailable = true;
    _updateTodaySteps();
  }

  void _updateTodaySteps() {
    final today = _dateKey(DateTime.now());
    StorageService.instance.getString(_baselineDateKey).then((savedDate) async {
      if (savedDate != today) {
        if (savedDate != null) {
          final prevSteps = _todaySteps;
          if (prevSteps > 0) _history[savedDate] = prevSteps;
          await _saveHistory();
        }
        _baseline = _rawSteps;
        await StorageService.instance.saveString(_baselineDateKey, today);
        await StorageService.instance.saveInt(_baselineKey, _baseline);
        await StorageService.instance.remove(_goalNotifiedKey);
      }

      _todaySteps = (_rawSteps - _baseline).clamp(0, 999999);
      await _syncWidget();
      await _checkGoalNotification();
      notifyListeners();
    });
  }

  Future<void> requestPermission() async {
    _permissionGranted = await StepService.instance.requestPermission();
    if (_permissionGranted) await _startListening();
    notifyListeners();
  }

  Future<void> setGoal(int goal) async {
    _goal = goal;
    await StorageService.instance.saveInt(_goalKey, goal);
    await _syncWidget();
    notifyListeners();
  }

  Future<void> setReminderEnabled(bool enabled) async {
    _reminderEnabled = enabled;
    await StorageService.instance.saveBool(_reminderEnabledKey, enabled);
    await _syncReminders();
    notifyListeners();
  }

  Future<void> setReminderInterval(int hours) async {
    _reminderIntervalHours = hours;
    await StorageService.instance.saveInt(_reminderIntervalKey, hours);
    await _syncReminders();
    notifyListeners();
  }

  Future<void> _syncReminders() async {
    await NotificationService.instance.updateSchedule(
      enabled: _reminderEnabled,
      intervalHours: _reminderIntervalHours,
    );
  }

  Future<void> _checkGoalNotification() async {
    if (!goalReached) return;
    final today = _dateKey(DateTime.now());
    final notified = await StorageService.instance.getString(_goalNotifiedKey);
    if (notified == today) return;
    await NotificationService.instance.showGoalAchieved(_goal);
    await StorageService.instance.saveString(_goalNotifiedKey, today);
  }

  Future<void> _syncWidget() async {
    final localeCode = await StorageService.instance.getString('app_locale') ?? 'en';
    await WidgetService.instance.updateWidget(
      steps: _todaySteps,
      goal: _goal,
      label: AppStrings.forLocale(localeCode, 'appName'),
    );
  }

  Future<void> _saveHistory() async {
    await StorageService.instance.saveString(_historyKey, jsonEncode(_history));
  }

  int stepsForDay(DateTime day) {
    final key = _dateKey(day);
    if (isSameDay(day, DateTime.now())) return _todaySteps;
    return _history[key] ?? 0;
  }

  List<int> weeklySteps() {
    final now = DateTime.now();
    return List.generate(7, (i) => stepsForDay(now.subtract(Duration(days: 6 - i))));
  }

  List<int> monthlySteps(DateTime month) {
    final start = startOfMonth(month);
    final total = daysInMonth(month);
    return List.generate(total, (i) {
      final day = DateTime(start.year, start.month, i + 1);
      return stepsForDay(day);
    });
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String motivationKey() {
    if (goalReached) return 'goalReached';
    if (progress >= 0.75) return 'almostThere';
    if (_todaySteps > 0) return 'keepWalking';
    return 'startWalking';
  }

  @override
  void dispose() {
    _stepSub?.cancel();
    _statusSub?.cancel();
    super.dispose();
  }
}
