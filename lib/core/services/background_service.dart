import 'package:battery_plus/battery_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import '../../data/models/battery_log.dart';
import '../../core/constants/app_constants.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(BatteryLogAdapter());
      }
      
      final logBox = await Hive.openBox<BatteryLog>(AppConstants.batteryBoxName);
      final settingsBox = await Hive.openBox(AppConstants.settingsBoxName);
      
      final battery = Battery();
      final level = await battery.batteryLevel;
      final status = await battery.batteryState;
      
      // Compute realistic simulated voltage, current, temperature
      double voltage = 3.7;
      double current = -0.2;
      double temp = 28.0;

      if (status == BatteryState.charging) {
        voltage = 3.9 + (level / 100.0) * 0.4; // 3.9V to 4.3V
        current = 1.2 + (1.0 - (level / 100.0)) * 1.8; // Fast charge to trickle
        temp = 32.0 + (level / 100.0) * 4.0; // Heat up while charging
      } else {
        voltage = 4.1 - (1.0 - (level / 100.0)) * 0.5; // 4.1V down to 3.6V
        current = -0.15 - (level < 20 ? 0.15 : 0.0); // More drain at low levels
        temp = 27.0 + (level / 100.0) * 2.0;
      }

      // Log data
      final log = BatteryLog(
        batteryLevel: level,
        batteryState: status.name,
        timestamp: DateTime.now(),
        voltage: double.parse(voltage.toStringAsFixed(2)),
        current: double.parse(current.toStringAsFixed(2)),
        temperature: double.parse(temp.toStringAsFixed(1)),
      );
      await logBox.add(log);
      
      // Read alert settings
      final lastLog = logBox.length > 1 ? logBox.values.elementAt(logBox.length - 2) : null;
      final alerts = settingsBox.get(AppConstants.customAlertsKey, defaultValue: [80, 20]) as List;
      final alertsList = alerts.cast<int>();
      
      // If we cross or hit any configured alert threshold
      if (alertsList.contains(level)) {
        // Prevent repeating notification if the level didn't change
        if (lastLog == null || lastLog.batteryLevel != level) {
          await NotificationService.init();
          await NotificationService.showNotification(
            id: level,
            title: 'Battery Alert',
            body: 'Your device battery has reached $level%',
          );

          // Add to alert history
          final list = settingsBox.get(AppConstants.alertHistoryKey, defaultValue: <String>[]) as List;
          final castedList = list.cast<String>();
          final now = DateTime.now();
          final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
          castedList.insert(0, '$timeStr | Level: $level% | State: ${status.name.toUpperCase()}');
          if (castedList.length > 50) {
            castedList.removeRange(50, castedList.length);
          }
          await settingsBox.put(AppConstants.alertHistoryKey, castedList);
        }
      }
    } catch (_) {
      // Gracefully catch background exceptions
    }
    
    return Future.value(true);
  });
}

class BackgroundService {
  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  static Future<void> registerPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      'battery_tracking_task',
      'batteryTracking',
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.not_required),
    );
  }
}

