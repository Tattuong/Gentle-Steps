import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'buoc_nhe_reminders';
  static const _channelName = 'Gentle Steps Reminders';

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Timezone init failed: $e');
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              description: 'Gentle reminders to keep walking',
            ),
          );
    }
  }

  Future<bool> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? true;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(alert: true, badge: true, sound: true) ?? true;
    }

    return true;
  }

  Future<void> updateSchedule({required bool enabled, required int intervalHours}) async {
    await _plugin.cancelAll();
    if (!enabled) return;

    final granted = await requestPermission();
    if (!granted) return;

    for (final hour in scheduleHours(intervalHours)) {
      await _scheduleDaily(hour);
    }
  }

  List<int> scheduleHours(int intervalHours) {
    final hours = <int>[];
    for (var hour = 9; hour <= 20; hour += intervalHours) {
      hours.add(hour);
    }
    return hours;
  }

  Future<void> _scheduleDaily(int hour) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Gentle reminders to keep walking',
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      hour,
      'Time to walk! 👟',
      'Move a bit more to reach your step goal today.',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> showGoalAchieved(int goal) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Goal achievement notifications',
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      999,
      'Goal reached! 🎉',
      'Congratulations! You hit $goal steps today!',
      details,
    );
  }
}
