import '../../data/models/battery_log.dart';

class BatteryEstimator {
  /// Calculate charging/discharging time remaining.
  /// If [isCharging] is true, returns the estimated duration until 100%.
  /// If false, returns the estimated duration until 0%.
  static Duration estimateTimeRemaining({
    required List<BatteryLog> logs,
    required int currentLevel,
    required bool isCharging,
  }) {
    if (logs.length < 2) {
      return _fallbackEstimation(currentLevel, isCharging);
    }

    final stateString = isCharging ? 'charging' : 'discharging';
    final stateLogs = logs
        .where((log) => log.batteryState.toLowerCase() == stateString)
        .toList();

    if (stateLogs.length < 2) {
      return _fallbackEstimation(currentLevel, isCharging);
    }

    // Sort by timestamp ascending
    stateLogs.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    double totalRate = 0.0;
    int weightCount = 0;

    for (int i = 1; i < stateLogs.length; i++) {
      final prev = stateLogs[i - 1];
      final curr = stateLogs[i];

      final diffMinutes =
          curr.timestamp.difference(prev.timestamp).inSeconds / 60.0;
      if (diffMinutes > 0.2) {
        // At least 12 seconds between logs
        final levelDiff = (curr.batteryLevel - prev.batteryLevel).abs();
        final rate = levelDiff / diffMinutes; // % per minute
        if (rate > 0) {
          totalRate += rate;
          weightCount++;
        }
      }
    }

    final avgRate = weightCount > 0 ? (totalRate / weightCount) : 0.0;

    // If avgRate is too small, fallback
    if (avgRate < 0.01) {
      return _fallbackEstimation(currentLevel, isCharging);
    }

    if (isCharging) {
      final percentNeeded = 100 - currentLevel;
      if (percentNeeded <= 0) return Duration.zero;
      final minutesRemaining = percentNeeded / avgRate;
      return Duration(minutes: minutesRemaining.round());
    } else {
      if (currentLevel <= 0) return Duration.zero;
      final minutesRemaining = currentLevel / avgRate;
      return Duration(minutes: minutesRemaining.round());
    }
  }

  static Duration _fallbackEstimation(int currentLevel, bool isCharging) {
    if (isCharging) {
      final percentNeeded = 100 - currentLevel;
      if (percentNeeded <= 0) return Duration.zero;
      return Duration(minutes: (percentNeeded * 1.5).round()); // 1.5 mins per %
    } else {
      if (currentLevel <= 0) return Duration.zero;
      return Duration(minutes: (currentLevel * 4.0).round()); // 4.0 mins per %
    }
  }

  /// Calculate average drain rate (% per hour) over the last 24h
  static double calculateAverageDrainRate(List<BatteryLog> logs) {
    if (logs.isEmpty) return 0.0;

    final now = DateTime.now();
    final oneDayAgo = now.subtract(const Duration(hours: 24));

    // Sort logs descending (newest first)
    final sortedLogs = List<BatteryLog>.from(logs)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final recentLogs =
        sortedLogs.where((log) => log.timestamp.isAfter(oneDayAgo)).toList();

    if (recentLogs.length < 2) {
      return 3.2; // Realistic fallback default (from the design screenshot)
    }

    // Find discharging periods
    double totalDrain = 0.0;
    double totalHours = 0.0;

    for (int i = 0; i < recentLogs.length - 1; i++) {
      final newer = recentLogs[i];
      final older = recentLogs[i + 1];

      // If we were discharging between these two logs
      if (newer.batteryState.toLowerCase() == 'discharging' &&
          older.batteryState.toLowerCase() == 'discharging') {
        final drain = older.batteryLevel - newer.batteryLevel;
        final timeDiffHours =
            newer.timestamp.difference(older.timestamp).inSeconds / 3600.0;

        if (drain >= 0 && timeDiffHours > 0) {
          totalDrain += drain;
          totalHours += timeDiffHours;
        }
      }
    }

    if (totalHours <= 0.05) {
      // If we don't have enough discharging log intervals, get overall change
      final oldest = recentLogs.last;
      final newest = recentLogs.first;
      final overallHours =
          newest.timestamp.difference(oldest.timestamp).inSeconds / 3600.0;
      if (overallHours > 0.05) {
        final levelDiff = oldest.batteryLevel - newest.batteryLevel;
        if (levelDiff > 0) {
          return levelDiff / overallHours;
        }
      }
      return 2.5; // Realistic fallback
    }

    return totalDrain / totalHours;
  }
}
