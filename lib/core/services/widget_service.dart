import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

class WidgetService {
  WidgetService._();
  static final WidgetService instance = WidgetService._();

  static const _androidWidgetName = 'StepWidgetProvider';
  static const _iosWidgetName = 'StepWidget';

  Future<void> init() async {
    try {
      await HomeWidget.setAppGroupId('group.com.GentleSteps.GentleSteps');
      await HomeWidget.registerInteractivityCallback(_backgroundCallback);
    } catch (e) {
      debugPrint('Widget init failed: $e');
    }
  }

  Future<void> updateWidget({
    required int steps,
    required int goal,
    required String label,
  }) async {
    try {
      await HomeWidget.saveWidgetData<int>('steps', steps);
      await HomeWidget.saveWidgetData<int>('goal', goal);
      await HomeWidget.saveWidgetData<String>('label', label);
      await HomeWidget.updateWidget(
        name: _androidWidgetName,
        iOSName: _iosWidgetName,
      );
    } catch (e) {
      debugPrint('Widget update failed: $e');
    }
  }
}

@pragma('vm:entry-point')
Future<void> _backgroundCallback(Uri? uri) async {
  // Reserved for widget tap interactions.
}
