import '../datasources/battery_local_datasource.dart';
import '../models/battery_log.dart';
import 'battery_repository.dart';

// Thin pass-through to the datasource. No logic here on purpose —
// Thin pass-through to the local storage datasource to keep the ViewModel
// agnostic of data persistence details.
class BatteryRepositoryImpl implements BatteryRepository {
  final BatteryLocalDatasource _datasource;

  const BatteryRepositoryImpl(this._datasource);

  // Logs
  @override
  Future<void> logBatteryStatus(BatteryLog log) =>
      _datasource.logBatteryStatus(log);

  @override
  Future<List<BatteryLog>> getBatteryLogs() => _datasource.getBatteryLogs();

  @override
  Future<void> clearLogs() => _datasource.clearLogs();

  // threshold
  @override
  Future<void> setThreshold(int v) => _datasource.setThreshold(v);

  @override
  Future<int> getThreshold() => _datasource.getThreshold();

  // warning offset
  @override
  Future<void> setWarningOffset(int v) => _datasource.setWarningOffset(v);

  @override
  Future<int> getWarningOffset() => _datasource.getWarningOffset();

  // theme
  @override
  Future<void> setThemeMode(bool v) => _datasource.setThemeMode(v);

  @override
  Future<bool> getThemeMode() => _datasource.getThemeMode();

  // polling interval
  @override
  Future<void> setPollingInterval(double v) =>
      _datasource.setPollingInterval(v);

  @override
  Future<double> getPollingInterval() => _datasource.getPollingInterval();

  // smoothing
  @override
  Future<void> setPredictiveSmoothing(bool v) =>
      _datasource.setPredictiveSmoothing(v);

  @override
  Future<bool> getPredictiveSmoothing() => _datasource.getPredictiveSmoothing();

  // high contrast
  @override
  Future<void> setHighContrast(bool v) => _datasource.setHighContrast(v);

  @override
  Future<bool> getHighContrast() => _datasource.getHighContrast();

  // absolute values
  @override
  Future<void> setAbsoluteValues(bool v) => _datasource.setAbsoluteValues(v);

  @override
  Future<bool> getAbsoluteValues() => _datasource.getAbsoluteValues();

  // haptics
  @override
  Future<void> setThresholdHaptics(bool v) =>
      _datasource.setThresholdHaptics(v);

  @override
  Future<bool> getThresholdHaptics() => _datasource.getThresholdHaptics();

  @override
  Future<void> setUiHaptics(bool v) => _datasource.setUiHaptics(v);

  @override
  Future<bool> getUiHaptics() => _datasource.getUiHaptics();

  // diagnostics
  @override
  Future<void> setDiagnosticsLastRun(String v) =>
      _datasource.setDiagnosticsLastRun(v);

  @override
  Future<String> getDiagnosticsLastRun() => _datasource.getDiagnosticsLastRun();

  @override
  Future<void> setDiagnosticsStatus(String v) =>
      _datasource.setDiagnosticsStatus(v);

  @override
  Future<String> getDiagnosticsStatus() => _datasource.getDiagnosticsStatus();

  // active profile
  @override
  Future<void> setActiveProfile(String v) => _datasource.setActiveProfile(v);

  @override
  Future<String> getActiveProfile() => _datasource.getActiveProfile();

  // custom alerts
  @override
  Future<List<int>> getCustomAlerts() => _datasource.getCustomAlerts();

  @override
  Future<void> addCustomAlert(int threshold) =>
      _datasource.addCustomAlert(threshold);

  @override
  Future<void> removeCustomAlert(int threshold) =>
      _datasource.removeCustomAlert(threshold);

  // alert history
  @override
  Future<List<String>> getAlertHistory() => _datasource.getAlertHistory();

  @override
  Future<void> addAlertHistoryLog(String message) =>
      _datasource.addAlertHistoryLog(message);

  @override
  Future<void> clearAlertHistory() => _datasource.clearAlertHistory();
}
