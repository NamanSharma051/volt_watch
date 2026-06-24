import '../models/battery_log.dart';

abstract class BatteryRepository {
  Future<void> logBatteryStatus(BatteryLog log);
  Future<List<BatteryLog>> getBatteryLogs();
  Future<void> clearLogs();
  
  Future<void> setThreshold(int threshold);
  Future<int> getThreshold();
  
  Future<void> setThemeMode(bool isDark);
  Future<bool> getThemeMode();

  Future<void> setWarningOffset(int offset);
  Future<int> getWarningOffset();

  Future<void> setPollingInterval(double seconds);
  Future<double> getPollingInterval();

  Future<void> setPredictiveSmoothing(bool enabled);
  Future<bool> getPredictiveSmoothing();

  Future<void> setHighContrast(bool enabled);
  Future<bool> getHighContrast();

  Future<void> setAbsoluteValues(bool enabled);
  Future<bool> getAbsoluteValues();

  Future<void> setThresholdHaptics(bool enabled);
  Future<bool> getThresholdHaptics();

  Future<void> setUiHaptics(bool enabled);
  Future<bool> getUiHaptics();

  Future<void> setDiagnosticsLastRun(String timestamp);
  Future<String> getDiagnosticsLastRun();

  Future<void> setDiagnosticsStatus(String status);
  Future<String> getDiagnosticsStatus();

  Future<void> setActiveProfile(String profileName);
  Future<String> getActiveProfile();

  Future<List<int>> getCustomAlerts();
  Future<void> addCustomAlert(int threshold);
  Future<void> removeCustomAlert(int threshold);

  Future<List<String>> getAlertHistory();
  Future<void> addAlertHistoryLog(String message);
  Future<void> clearAlertHistory();
}

