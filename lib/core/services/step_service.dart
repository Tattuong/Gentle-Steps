import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class StepService {
  StepService._();
  static final StepService instance = StepService._();

  Stream<StepCount>? _stepStream;
  Stream<PedestrianStatus>? _statusStream;

  Stream<StepCount> get stepStream {
    _stepStream ??= Pedometer.stepCountStream;
    return _stepStream!;
  }

  Stream<PedestrianStatus> get statusStream {
    _statusStream ??= Pedometer.pedestrianStatusStream;
    return _statusStream!;
  }

  Future<bool> requestPermission() async {
    if (!Platform.isAndroid) return true;
    try {
      final status = await Permission.activityRecognition.status;
      if (status.isGranted) return true;
      final result = await Permission.activityRecognition.request();
      return result.isGranted;
    } catch (e) {
      debugPrint('Permission request failed: $e');
      return false;
    }
  }

  Future<bool> hasPermission() async {
    if (!Platform.isAndroid) return true;
    try {
      return (await Permission.activityRecognition.status).isGranted;
    } catch (_) {
      return false;
    }
  }
}
