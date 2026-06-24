import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/battery_viewmodel.dart';
import '../viewmodels/providers.dart';
import '../widgets/battery_gauge.dart';
import '../widgets/consumption_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // High Contrast configuration overrides
    final Color cardColor = settings.highContrastMode
        ? (isDark ? Colors.black : Colors.white)
        : (isDark ? const Color(0xFF14171A) : Colors.white);
        
    final Color borderColor = settings.highContrastMode
        ? (isDark ? Colors.white : Colors.black)
        : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05));
        
    final double borderThickness = settings.highContrastMode ? 2.0 : 1.0;
    
    final Color scaffoldBgColor = settings.highContrastMode
        ? (isDark ? Colors.black : Colors.white)
        : (isDark ? const Color(0xFF0B0D0E) : Colors.grey[100]!);

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            const Icon(Icons.bolt, color: Color(0xFF00FF88), size: 24),
            const SizedBox(width: 8),
            Text(
              'VOLTWATCH',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: const Color(0xFF00FF88),
            ),
            tooltip: 'Toggle Theme Mode',
            onPressed: () {
              if (settings.uiHaptics) {
                HapticFeedback.mediumImpact();
              }
              ref.read(settingsViewModelProvider.notifier).toggleTheme(!settings.isDarkMode);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            
            // 1. Double Ring Cyberpunk Battery Gauge (Only rebuilds when battery level/status changes)
            Consumer(
              builder: (context, ref, child) {
                final level = ref.watch(batteryViewModelProvider.select((s) => s.level));
                final status = ref.watch(batteryViewModelProvider.select((s) => s.statusName));
                return BatteryGauge(
                  level: level,
                  status: status,
                );
              },
            ),
            
            const SizedBox(height: 24),

            // 2. Telemetry Info Mini Cards Row (Only rebuilds on estimatedTime, status, level or health changes)
            Consumer(
              builder: (context, ref, child) {
                final estimatedTime = ref.watch(batteryViewModelProvider.select((s) => s.estimatedTime));
                final status = ref.watch(batteryViewModelProvider.select((s) => s.status));
                final level = ref.watch(batteryViewModelProvider.select((s) => s.level));
                final health = ref.watch(batteryViewModelProvider.select((s) => s.health));
                final localPrimaryColor = _getBatteryColor(level);

                return Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor, width: borderThickness),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.timer_outlined, color: localPrimaryColor, size: 20),
                            const SizedBox(height: 8),
                            Text(
                              estimatedTime,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              status == BatteryStateEnum.charging ? 'To Full Charge' : 'Time Left',
                              style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor, width: borderThickness),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.security, color: Color(0xFF00FF88), size: 20),
                            const SizedBox(height: 8),
                            Text(
                              '$health%',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Battery Health',
                              style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // 3. Power Source Telemetry Table (Updates every second, but limited to a lightweight table)
            Consumer(
              builder: (context, ref, child) {
                final status = ref.watch(batteryViewModelProvider.select((s) => s.status));
                final level = ref.watch(batteryViewModelProvider.select((s) => s.level));
                final voltage = ref.watch(batteryViewModelProvider.select((s) => s.voltage));
                final current = ref.watch(batteryViewModelProvider.select((s) => s.current));
                final wattage = ref.watch(batteryViewModelProvider.select((s) => s.wattage));
                final temperature = ref.watch(batteryViewModelProvider.select((s) => s.temperature));
                final localPrimaryColor = _getBatteryColor(level);

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: borderThickness),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Power Source',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          Icon(
                            status == BatteryStateEnum.charging ? Icons.power : Icons.battery_charging_full,
                            color: localPrimaryColor,
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        status == BatteryStateEnum.charging ? 'AC Adapter (Active)' : 'Internal Battery',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blue),
                      ),
                      const SizedBox(height: 18),
                      
                      // Telemetry Rows
                      _buildTelemetryRow('Voltage', '$voltage V', isDark),
                      const Divider(color: Colors.white10, height: 16),
                      _buildTelemetryRow(
                        'Current',
                        settings.absoluteValues
                            ? '${current.abs().toStringAsFixed(2)} A'
                            : '${current > 0 ? "+" : ""}${current.toStringAsFixed(2)} A',
                        isDark,
                        valueColor: current >= 0 ? const Color(0xFF00FF88) : const Color(0xFFFF3B30),
                      ),
                      const Divider(color: Colors.white10, height: 16),
                      _buildTelemetryRow(
                        'Wattage',
                        settings.absoluteValues
                            ? '${wattage.abs().toStringAsFixed(1)} W'
                            : '${wattage.toStringAsFixed(1)} W',
                        isDark,
                        valueColor: current >= 0 ? const Color(0xFF00FF88) : (isDark ? Colors.white : Colors.black87),
                      ),
                      const Divider(color: Colors.white10, height: 16),
                      _buildTelemetryRow('Temp', '$temperature °C', isDark),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // 4. Consumption Rate Bar Chart (Only rebuilds when logs update, not every second)
            Consumer(
              builder: (context, ref, child) {
                final logs = ref.watch(batteryViewModelProvider.select((s) => s.logs));
                final consumptionValues = logs.isEmpty
                    ? <double>[]
                    : logs
                        .take(8)
                        .map((log) => (log.voltage ?? 3.7) * (log.current ?? 0.2).abs())
                        .toList()
                        .reversed
                        .toList();

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: borderThickness),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Consumption Rate',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 120,
                        child: RepaintBoundary(
                          child: ConsumptionChart(
                            consumptionValues: consumptionValues,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryRow(String label, String value, bool isDark, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black45),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            color: valueColor ?? (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }

  Color _getBatteryColor(int level) {
    if (level >= 80) return const Color(0xFF00FF88);
    if (level >= 40) return const Color(0xFFFFDD00);
    return const Color(0xFFFF3B30);
  }
}
