import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../viewmodels/providers.dart';
import '../widgets/battery_chart.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color cardColor = isDark ? const Color(0xFF14171A) : Colors.white;
    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0D0E) : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            const Icon(Icons.analytics, color: Color(0xFF00FF88), size: 24),
            const SizedBox(width: 8),
            Text(
              'POWER HISTORY',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final settings = ref.read(settingsViewModelProvider);
          if (settings.uiHaptics) {
            HapticFeedback.mediumImpact();
          }
          await ref.read(batteryViewModelProvider.notifier).refreshLogs();
        },
        color: const Color(0xFF00FF88),
        backgroundColor: cardColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Telemetry Highlights Row
              Consumer(
                builder: (context, ref, child) {
                  final logs =
                      ref.watch(batteryViewModelProvider.select((s) => s.logs));
                  final dailyDrainRate = ref.watch(
                      batteryViewModelProvider.select((s) => s.dailyDrainRate));
                  final level = ref
                      .watch(batteryViewModelProvider.select((s) => s.level));

                  // Compute Peak and Critical values from logs
                  double peakLevel = level.toDouble();
                  String peakTime =
                      DateFormat('HH:mm:ss').format(DateTime.now());
                  double criticalLow = level.toDouble();
                  String criticalTime =
                      DateFormat('HH:mm:ss').format(DateTime.now());

                  if (logs.isNotEmpty) {
                    // Find peak
                    final peakLog = logs.reduce((curr, next) =>
                        curr.batteryLevel > next.batteryLevel ? curr : next);
                    peakLevel = peakLog.batteryLevel.toDouble();
                    peakTime = DateFormat('HH:mm:ss').format(peakLog.timestamp);

                    // Find critical low
                    final lowLog = logs.reduce((curr, next) =>
                        curr.batteryLevel < next.batteryLevel ? curr : next);
                    criticalLow = lowLog.batteryLevel.toDouble();
                    criticalTime =
                        DateFormat('HH:mm:ss').format(lowLog.timestamp);
                  }

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AVG DRAIN RATE',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white38 : Colors.black45),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '$dailyDrainRate%',
                              style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace'),
                            ),
                            Text(
                              '/hr',
                              style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      isDark ? Colors.white38 : Colors.black45,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PEAK LEVEL',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white38
                                            : Colors.black45),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${peakLevel.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87),
                                  ),
                                  Text(
                                    '${peakTime}Z',
                                    style: TextStyle(
                                        fontSize: 9,
                                        color: isDark
                                            ? Colors.white24
                                            : Colors.black38,
                                        fontFamily: 'monospace'),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                                width: 1,
                                height: 40,
                                color:
                                    isDark ? Colors.white10 : Colors.black12),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CRITICAL LOW',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white38
                                            : Colors.black45),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${criticalLow.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFF3B30)),
                                  ),
                                  Text(
                                    '${criticalTime}Z',
                                    style: TextStyle(
                                        fontSize: 9,
                                        color: isDark
                                            ? Colors.white24
                                            : Colors.black38,
                                        fontFamily: 'monospace'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // 2. Discharge Curve Shaded Area Chart
              Container(
                height: 280,
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: RepaintBoundary(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final logs = ref.watch(
                          batteryViewModelProvider.select((s) => s.logs));
                      return BatteryChart(logs: logs);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 3. Telemetry Log Table
              Text(
                'TELEMETRY LOG',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 12),

              Consumer(
                builder: (context, ref, child) {
                  final logs =
                      ref.watch(batteryViewModelProvider.select((s) => s.logs));

                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white10
                                : Colors.black.withValues(alpha: 0.05),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'TIMESTAMP (Z)',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.black54),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'LEVEL',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.black54),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'STATE',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.black54),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'VOLTAGE(V)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Table Rows
                        if (logs.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text('No telemetry logs logged yet.'),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              final log = logs[index];
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: isDark
                                              ? Colors.white10
                                              : Colors.black12,
                                          width: 0.5)),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: Row(
                                  children: [
                                    // Time
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        DateFormat('HH:mm:ss')
                                            .format(log.timestamp),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'monospace'),
                                      ),
                                    ),
                                    // Level
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${log.batteryLevel}.0%',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'monospace'),
                                      ),
                                    ),
                                    // State Tag
                                    Expanded(
                                      flex: 3,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: _buildStateTag(
                                            log.batteryLevel, log.batteryState),
                                      ),
                                    ),
                                    // Voltage
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${log.voltage ?? 12.00}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'monospace',
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black87,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateTag(int level, String state) {
    Color tagColor = Colors.grey;
    String label = state.toUpperCase();

    if (state.toLowerCase() == 'charging') {
      tagColor = const Color(0xFF00FF88);
      label = 'CHARGING';
    } else if (level < 20) {
      tagColor = const Color(0xFFFF3B30);
      label = 'CRITICAL';
    } else if (state.toLowerCase() == 'discharging') {
      tagColor = const Color(0xFF90A4AE);
      label = 'DISCHARGING';
    } else {
      tagColor = const Color(0xFF00E5FF);
      label = 'OPTIMIZED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tagColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: tagColor.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tagColor,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
