import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/battery_repository.dart';

class SettingsState {
  final int threshold;
  final int warningOffset;
  final bool isDarkMode;
  final double pollingInterval;
  final bool predictiveSmoothing;
  final bool highContrastMode;
  final bool absoluteValues;
  final bool thresholdHaptics;
  final bool uiHaptics;
  final String diagnosticsLastRun;
  final String diagnosticsStatus;
  final bool isExecutingDiagnostics;
  final String activeProfile;
  final List<int> customAlerts;
  final List<String> alertHistory;

  SettingsState({
    required this.threshold,
    required this.warningOffset,
    required this.isDarkMode,
    required this.pollingInterval,
    required this.predictiveSmoothing,
    required this.highContrastMode,
    required this.absoluteValues,
    required this.thresholdHaptics,
    required this.uiHaptics,
    required this.diagnosticsLastRun,
    required this.diagnosticsStatus,
    required this.isExecutingDiagnostics,
    required this.activeProfile,
    required this.customAlerts,
    required this.alertHistory,
  });

  SettingsState copyWith({
    int? threshold,
    int? warningOffset,
    bool? isDarkMode,
    double? pollingInterval,
    bool? predictiveSmoothing,
    bool? highContrastMode,
    bool? absoluteValues,
    bool? thresholdHaptics,
    bool? uiHaptics,
    String? diagnosticsLastRun,
    String? diagnosticsStatus,
    bool? isExecutingDiagnostics,
    String? activeProfile,
    List<int>? customAlerts,
    List<String>? alertHistory,
  }) {
    return SettingsState(
      threshold: threshold ?? this.threshold,
      warningOffset: warningOffset ?? this.warningOffset,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      pollingInterval: pollingInterval ?? this.pollingInterval,
      predictiveSmoothing: predictiveSmoothing ?? this.predictiveSmoothing,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      absoluteValues: absoluteValues ?? this.absoluteValues,
      thresholdHaptics: thresholdHaptics ?? this.thresholdHaptics,
      uiHaptics: uiHaptics ?? this.uiHaptics,
      diagnosticsLastRun: diagnosticsLastRun ?? this.diagnosticsLastRun,
      diagnosticsStatus: diagnosticsStatus ?? this.diagnosticsStatus,
      isExecutingDiagnostics: isExecutingDiagnostics ?? this.isExecutingDiagnostics,
      activeProfile: activeProfile ?? this.activeProfile,
      customAlerts: customAlerts ?? this.customAlerts,
      alertHistory: alertHistory ?? this.alertHistory,
    );
  }
}

class SettingsViewModel extends StateNotifier<SettingsState> {
  final BatteryRepository _repository;

  SettingsViewModel(this._repository)
      : super(SettingsState(
          threshold: 15,
          warningOffset: 10,
          isDarkMode: true,
          pollingInterval: 1.0,
          predictiveSmoothing: true,
          highContrastMode: false,
          absoluteValues: true,
          thresholdHaptics: true,
          uiHaptics: false,
          diagnosticsLastRun: '08:42:11 UTC',
          diagnosticsStatus: 'NOMINAL',
          isExecutingDiagnostics: false,
          activeProfile: 'High Performance',
          customAlerts: [80, 20],
          alertHistory: [],
        )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final threshold = await _repository.getThreshold();
    final warningOffset = await _repository.getWarningOffset();
    final isDarkMode = await _repository.getThemeMode();
    final pollingInterval = await _repository.getPollingInterval();
    final predictiveSmoothing = await _repository.getPredictiveSmoothing();
    final highContrastMode = await _repository.getHighContrast();
    final absoluteValues = await _repository.getAbsoluteValues();
    final thresholdHaptics = await _repository.getThresholdHaptics();
    final uiHaptics = await _repository.getUiHaptics();
    final diagnosticsLastRun = await _repository.getDiagnosticsLastRun();
    final diagnosticsStatus = await _repository.getDiagnosticsStatus();
    final activeProfile = await _repository.getActiveProfile();
    final customAlerts = await _repository.getCustomAlerts();
    final alertHistory = await _repository.getAlertHistory();

    state = SettingsState(
      threshold: threshold,
      warningOffset: warningOffset,
      isDarkMode: isDarkMode,
      pollingInterval: pollingInterval,
      predictiveSmoothing: predictiveSmoothing,
      highContrastMode: highContrastMode,
      absoluteValues: absoluteValues,
      thresholdHaptics: thresholdHaptics,
      uiHaptics: uiHaptics,
      diagnosticsLastRun: diagnosticsLastRun,
      diagnosticsStatus: diagnosticsStatus,
      isExecutingDiagnostics: false,
      activeProfile: activeProfile,
      customAlerts: customAlerts,
      alertHistory: alertHistory,
    );
  }

  Future<void> setThreshold(int value) async {
    await _repository.setThreshold(value);
    state = state.copyWith(threshold: value);
  }

  Future<void> setWarningOffset(int value) async {
    await _repository.setWarningOffset(value);
    state = state.copyWith(warningOffset: value);
  }

  Future<void> toggleTheme(bool value) async {
    await _repository.setThemeMode(value);
    state = state.copyWith(isDarkMode: value);
  }

  Future<void> setPollingInterval(double value) async {
    await _repository.setPollingInterval(value);
    state = state.copyWith(pollingInterval: value);
  }

  Future<void> togglePredictiveSmoothing(bool value) async {
    await _repository.setPredictiveSmoothing(value);
    state = state.copyWith(predictiveSmoothing: value);
  }

  Future<void> toggleHighContrast(bool value) async {
    await _repository.setHighContrast(value);
    state = state.copyWith(highContrastMode: value);
  }

  Future<void> toggleAbsoluteValues(bool value) async {
    await _repository.setAbsoluteValues(value);
    state = state.copyWith(absoluteValues: value);
  }

  Future<void> toggleThresholdHaptics(bool value) async {
    await _repository.setThresholdHaptics(value);
    state = state.copyWith(thresholdHaptics: value);
  }

  Future<void> toggleUiHaptics(bool value) async {
    await _repository.setUiHaptics(value);
    state = state.copyWith(uiHaptics: value);
  }

  Future<void> setActiveProfile(String value) async {
    await _repository.setActiveProfile(value);
    state = state.copyWith(activeProfile: value);
    
    // Automatically configure parameters based on preset
    if (value == 'High Performance') {
      await setPollingInterval(1.0);
      await togglePredictiveSmoothing(true);
      await toggleThresholdHaptics(true);
    } else if (value == 'Battery Saver') {
      await setPollingInterval(15.0);
      await togglePredictiveSmoothing(false);
      await toggleThresholdHaptics(false);
    }
  }

  Future<void> executeDiagnostics() async {
    state = state.copyWith(isExecutingDiagnostics: true);
    
    // Simulate telemetry diagnostic tests (e.g. 2s wait)
    await Future.delayed(const Duration(seconds: 2));
    
    final nowStr = DateFormat('HH:mm:ss').format(DateTime.now()) + ' UTC';
    await _repository.setDiagnosticsLastRun(nowStr);
    await _repository.setDiagnosticsStatus('NOMINAL');
    
    state = state.copyWith(
      isExecutingDiagnostics: false,
      diagnosticsLastRun: nowStr,
      diagnosticsStatus: 'NOMINAL',
    );
  }

  Future<void> addCustomAlert(int threshold) async {
    await _repository.addCustomAlert(threshold);
    final alerts = await _repository.getCustomAlerts();
    state = state.copyWith(customAlerts: alerts);
  }

  Future<void> removeCustomAlert(int threshold) async {
    await _repository.removeCustomAlert(threshold);
    final alerts = await _repository.getCustomAlerts();
    state = state.copyWith(customAlerts: alerts);
  }

  Future<void> addAlertHistoryLog(String message) async {
    await _repository.addAlertHistoryLog(message);
    final history = await _repository.getAlertHistory();
    state = state.copyWith(alertHistory: history);
  }

  Future<void> clearAlertHistory() async {
    await _repository.clearAlertHistory();
    state = state.copyWith(alertHistory: []);
  }

  Future<void> resetToDefaults() async {
    await setThreshold(80);
    await setWarningOffset(10);
    await toggleTheme(true);
    await setPollingInterval(1.0);
    await togglePredictiveSmoothing(true);
    await toggleHighContrast(false);
    await toggleAbsoluteValues(true);
    await toggleThresholdHaptics(true);
    await toggleUiHaptics(false);
    await setActiveProfile('High Performance');
  }
}

