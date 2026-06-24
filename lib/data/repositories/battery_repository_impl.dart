import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/battery_log.dart';
import 'battery_repository.dart';

class BatteryRepositoryImpl implements BatteryRepository {
  final Box<BatteryLog> _logBox;
  final Box _settingsBox;

  BatteryRepositoryImpl(this._logBox, this._settingsBox);

  @override
  Future<void> logBatteryStatus(BatteryLog log) async {
    await _logBox.add(log);
  }

  @override
  Future<List<BatteryLog>> getBatteryLogs() async {
    return _logBox.values.toList().reversed.toList();
  }

  @override
  Future<void> clearLogs() async {
    await _logBox.clear();
  }

  @override
  Future<void> setThreshold(int threshold) async {
    await _settingsBox.put(AppConstants.thresholdKey, threshold);
  }

  @override
  Future<int> getThreshold() async {
    return _settingsBox.get(AppConstants.thresholdKey, defaultValue: 15);
  }

  @override
  Future<void> setThemeMode(bool isDark) async {
    await _settingsBox.put(AppConstants.themeKey, isDark);
  }

  @override
  Future<bool> getThemeMode() async {
    return _settingsBox.get(AppConstants.themeKey, defaultValue: true); // Default to dark mode as requested by cyberpunk styling
  }

  @override
  Future<void> setWarningOffset(int offset) async {
    await _settingsBox.put(AppConstants.warningOffsetKey, offset);
  }

  @override
  Future<int> getWarningOffset() async {
    return _settingsBox.get(AppConstants.warningOffsetKey, defaultValue: 10);
  }

  @override
  Future<void> setPollingInterval(double seconds) async {
    await _settingsBox.put(AppConstants.pollingIntervalKey, seconds);
  }

  @override
  Future<double> getPollingInterval() async {
    return _settingsBox.get(AppConstants.pollingIntervalKey, defaultValue: 1.0);
  }

  @override
  Future<void> setPredictiveSmoothing(bool enabled) async {
    await _settingsBox.put(AppConstants.predictiveSmoothingKey, enabled);
  }

  @override
  Future<bool> getPredictiveSmoothing() async {
    return _settingsBox.get(AppConstants.predictiveSmoothingKey, defaultValue: true);
  }

  @override
  Future<void> setHighContrast(bool enabled) async {
    await _settingsBox.put(AppConstants.highContrastKey, enabled);
  }

  @override
  Future<bool> getHighContrast() async {
    return _settingsBox.get(AppConstants.highContrastKey, defaultValue: false);
  }

  @override
  Future<void> setAbsoluteValues(bool enabled) async {
    await _settingsBox.put(AppConstants.absoluteValuesKey, enabled);
  }

  @override
  Future<bool> getAbsoluteValues() async {
    return _settingsBox.get(AppConstants.absoluteValuesKey, defaultValue: true);
  }

  @override
  Future<void> setThresholdHaptics(bool enabled) async {
    await _settingsBox.put(AppConstants.thresholdHapticsKey, enabled);
  }

  @override
  Future<bool> getThresholdHaptics() async {
    return _settingsBox.get(AppConstants.thresholdHapticsKey, defaultValue: true);
  }

  @override
  Future<void> setUiHaptics(bool enabled) async {
    await _settingsBox.put(AppConstants.uiHapticsKey, enabled);
  }

  @override
  Future<bool> getUiHaptics() async {
    return _settingsBox.get(AppConstants.uiHapticsKey, defaultValue: false);
  }

  @override
  Future<void> setDiagnosticsLastRun(String timestamp) async {
    await _settingsBox.put(AppConstants.diagnosticsLastRunKey, timestamp);
  }

  @override
  Future<String> getDiagnosticsLastRun() async {
    return _settingsBox.get(AppConstants.diagnosticsLastRunKey, defaultValue: '08:42:11 UTC');
  }

  @override
  Future<void> setDiagnosticsStatus(String status) async {
    await _settingsBox.put(AppConstants.diagnosticsStatusKey, status);
  }

  @override
  Future<String> getDiagnosticsStatus() async {
    return _settingsBox.get(AppConstants.diagnosticsStatusKey, defaultValue: 'NOMINAL');
  }

  @override
  Future<void> setActiveProfile(String profileName) async {
    await _settingsBox.put(AppConstants.activeProfileKey, profileName);
  }

  @override
  Future<String> getActiveProfile() async {
    return _settingsBox.get(AppConstants.activeProfileKey, defaultValue: 'High Performance');
  }

  @override
  Future<List<int>> getCustomAlerts() async {
    final list = _settingsBox.get(AppConstants.customAlertsKey, defaultValue: [80, 20]);
    if (list is List) {
      return list.cast<int>();
    }
    return [80, 20];
  }

  @override
  Future<void> addCustomAlert(int threshold) async {
    final alerts = await getCustomAlerts();
    if (!alerts.contains(threshold)) {
      alerts.add(threshold);
      alerts.sort();
      await _settingsBox.put(AppConstants.customAlertsKey, alerts);
    }
  }

  @override
  Future<void> removeCustomAlert(int threshold) async {
    final alerts = await getCustomAlerts();
    if (alerts.contains(threshold)) {
      alerts.remove(threshold);
      await _settingsBox.put(AppConstants.customAlertsKey, alerts);
    }
  }

  @override
  Future<List<String>> getAlertHistory() async {
    final list = _settingsBox.get(AppConstants.alertHistoryKey, defaultValue: <String>[]);
    if (list is List) {
      return list.cast<String>();
    }
    return <String>[];
  }

  @override
  Future<void> addAlertHistoryLog(String message) async {
    final list = await getAlertHistory();
    list.insert(0, message);
    if (list.length > 50) {
      list.removeRange(50, list.length);
    }
    await _settingsBox.put(AppConstants.alertHistoryKey, list);
  }

  @override
  Future<void> clearAlertHistory() async {
    await _settingsBox.put(AppConstants.alertHistoryKey, <String>[]);
  }
}

