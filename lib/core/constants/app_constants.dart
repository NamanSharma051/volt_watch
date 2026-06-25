class AppConstants {
  static const String appName = 'VoltWatch';
  static const String batteryBoxName = 'battery_logs';
  static const String settingsBoxName = 'settings';

  static const String thresholdKey = 'battery_threshold';
  static const String warningOffsetKey = 'warning_offset';
  static const String themeKey = 'is_dark_mode';

  // Advanced Telemetry Settings Keys
  static const String pollingIntervalKey = 'polling_interval';
  static const String predictiveSmoothingKey = 'predictive_smoothing';
  static const String highContrastKey = 'high_contrast_mode';
  static const String absoluteValuesKey = 'absolute_values';
  static const String thresholdHapticsKey = 'threshold_haptics';
  static const String uiHapticsKey = 'ui_haptics';
  static const String diagnosticsLastRunKey = 'diagnostics_last_run';
  static const String diagnosticsStatusKey = 'diagnostics_status';
  static const String activeProfileKey = 'active_profile';
  static const String customAlertsKey = 'custom_alerts_list';
  static const String alertHistoryKey = 'alert_history_logs';

  static const int backgroundIntervalMinutes = 15;

  // Colors (Aesthetic neon/slate color codes)
  static const int colorGreen = 0xFF00FF88; // Neon Green
  static const int colorYellow = 0xFFFFDD00; // Vibrant Cyberpunk Yellow
  static const int colorRed = 0xFFFF3B30; // Alert Red
  static const int colorBgDark = 0xFF0B0D0E; // Deep Slate Space Black
  static const int colorCardDark = 0xFF14171A; // Cyberpunk Card Dark Gray
}
