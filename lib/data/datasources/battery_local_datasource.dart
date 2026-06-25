import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/battery_log.dart';

// All actual Hive reads/writes live here. Nothing above this layer should
// ever call box.get or box.put directly.
class BatteryLocalDatasource {
  final Box<BatteryLog> logBox;
  final Box settingsBox;

  const BatteryLocalDatasource(
      {required this.logBox, required this.settingsBox});

  // logs

  Future<void> logBatteryStatus(BatteryLog log) => logBox.add(log);

  Future<List<BatteryLog>> getBatteryLogs() async =>
      logBox.values.toList().reversed.toList();

  Future<void> clearLogs() => logBox.clear();

  // threshold — clamped to 5-30, slider blew up once when this wasn't guarded

  Future<void> setThreshold(int v) =>
      settingsBox.put(AppConstants.thresholdKey, v.clamp(5, 30));

  Future<int> getThreshold() async {
    final raw =
        settingsBox.get(AppConstants.thresholdKey, defaultValue: 15) as int;
    return raw.clamp(5, 30);
  }

  // warning offset (a few % before the threshold fires)

  Future<void> setWarningOffset(int v) =>
      settingsBox.put(AppConstants.warningOffsetKey, v);

  Future<int> getWarningOffset() async =>
      settingsBox.get(AppConstants.warningOffsetKey, defaultValue: 10) as int;

  // dark / light preference

  Future<void> setThemeMode(bool v) =>
      settingsBox.put(AppConstants.themeKey, v);

  Future<bool> getThemeMode() async =>
      settingsBox.get(AppConstants.themeKey, defaultValue: true) as bool;

  // how often the viewmodel polls battery data (1s / 5s / 15s)

  Future<void> setPollingInterval(double v) =>
      settingsBox.put(AppConstants.pollingIntervalKey, v);

  Future<double> getPollingInterval() async =>
      (settingsBox.get(AppConstants.pollingIntervalKey, defaultValue: 1.0)
              as num)
          .toDouble();

  // kalman smoothing toggle

  Future<void> setPredictiveSmoothing(bool v) =>
      settingsBox.put(AppConstants.predictiveSmoothingKey, v);

  Future<bool> getPredictiveSmoothing() async =>
      settingsBox.get(AppConstants.predictiveSmoothingKey, defaultValue: true)
          as bool;

  // high contrast mode

  Future<void> setHighContrast(bool v) =>
      settingsBox.put(AppConstants.highContrastKey, v);

  Future<bool> getHighContrast() async =>
      settingsBox.get(AppConstants.highContrastKey, defaultValue: false)
          as bool;

  // show raw absolute values vs relative

  Future<void> setAbsoluteValues(bool v) =>
      settingsBox.put(AppConstants.absoluteValuesKey, v);

  Future<bool> getAbsoluteValues() async =>
      settingsBox.get(AppConstants.absoluteValuesKey, defaultValue: true)
          as bool;

  // haptics — two separate toggles, one for alerts, one for UI taps

  Future<void> setThresholdHaptics(bool v) =>
      settingsBox.put(AppConstants.thresholdHapticsKey, v);

  Future<bool> getThresholdHaptics() async =>
      settingsBox.get(AppConstants.thresholdHapticsKey, defaultValue: true)
          as bool;

  Future<void> setUiHaptics(bool v) =>
      settingsBox.put(AppConstants.uiHapticsKey, v);

  Future<bool> getUiHaptics() async =>
      settingsBox.get(AppConstants.uiHapticsKey, defaultValue: false) as bool;

  // last diagnostics run timestamp + result string

  Future<void> setDiagnosticsLastRun(String v) =>
      settingsBox.put(AppConstants.diagnosticsLastRunKey, v);

  Future<String> getDiagnosticsLastRun() async =>
      settingsBox.get(AppConstants.diagnosticsLastRunKey,
          defaultValue: '--:--:-- UTC') as String;

  Future<void> setDiagnosticsStatus(String v) =>
      settingsBox.put(AppConstants.diagnosticsStatusKey, v);

  Future<String> getDiagnosticsStatus() async =>
      settingsBox.get(AppConstants.diagnosticsStatusKey,
          defaultValue: 'NOMINAL') as String;

  // active preset profile (High Performance / Battery Saver)

  Future<void> setActiveProfile(String v) =>
      settingsBox.put(AppConstants.activeProfileKey, v);

  Future<String> getActiveProfile() async =>
      settingsBox.get(AppConstants.activeProfileKey,
          defaultValue: 'High Performance') as String;

  // user-defined alert thresholds, stored as a plain int list

  Future<List<int>> getCustomAlerts() async {
    final raw =
        settingsBox.get(AppConstants.customAlertsKey, defaultValue: [80, 20]);
    return (raw is List) ? raw.cast<int>() : [80, 20];
  }

  Future<void> addCustomAlert(int threshold) async {
    final alerts = await getCustomAlerts();
    if (!alerts.contains(threshold)) {
      alerts
        ..add(threshold)
        ..sort();
      await settingsBox.put(AppConstants.customAlertsKey, alerts);
    }
  }

  Future<void> removeCustomAlert(int threshold) async {
    final alerts = await getCustomAlerts();
    if (alerts.remove(threshold)) {
      await settingsBox.put(AppConstants.customAlertsKey, alerts);
    }
  }

  // timestamped strings of past alert triggers, capped at 50 entries

  Future<List<String>> getAlertHistory() async {
    final raw =
        settingsBox.get(AppConstants.alertHistoryKey, defaultValue: <String>[]);
    return (raw is List) ? raw.cast<String>() : <String>[];
  }

  Future<void> addAlertHistoryLog(String message) async {
    final list = await getAlertHistory();
    list.insert(0, message);
    if (list.length > 50) list.removeRange(50, list.length);
    await settingsBox.put(AppConstants.alertHistoryKey, list);
  }

  Future<void> clearAlertHistory() =>
      settingsBox.put(AppConstants.alertHistoryKey, <String>[]);
}
