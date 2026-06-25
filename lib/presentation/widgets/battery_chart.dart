import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/battery_log.dart';

class BatteryChart extends StatefulWidget {
  final List<BatteryLog> logs;

  const BatteryChart({super.key, required this.logs});

  @override
  State<BatteryChart> createState() => _BatteryChartState();
}

class _BatteryChartState extends State<BatteryChart> {
  String _activeFilter = '24H'; // 'Live', '1H', '24H'

  List<BatteryLog> _getFilteredLogs() {
    if (widget.logs.isEmpty) return [];

    final now = DateTime.now();
    List<BatteryLog> filtered = [];

    if (_activeFilter == 'Live') {
      // Last 10 records
      filtered = widget.logs.take(10).toList();
    } else if (_activeFilter == '1H') {
      // Last 1 hour
      final oneHourAgo = now.subtract(const Duration(hours: 1));
      filtered = widget.logs
          .where((log) => log.timestamp.isAfter(oneHourAgo))
          .toList();
    } else {
      // Last 24 hours
      final oneDayAgo = now.subtract(const Duration(hours: 24));
      filtered =
          widget.logs.where((log) => log.timestamp.isAfter(oneDayAgo)).toList();
    }

    // Sort chronologically for chart drawing (ascending)
    filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredLogs = _getFilteredLogs();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Chart Header with Filter Tabs
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DISCHARGE CURVE ($_activeFilter)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(2),
              child: Row(
                children: ['Live', '1H', '24H'].map((filter) {
                  final isActive = _activeFilter == filter;
                  return GestureDetector(
                    onTap: () => setState(() => _activeFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? (isDark ? const Color(0xFF1E3A3A) : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(3),
                        border: isActive && isDark
                            ? Border.all(
                                color: const Color(0xFF00FF88).withValues(alpha: 0.3),
                                width: 1)
                            : null,
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? (isDark
                                  ? const Color(0xFF00FF88)
                                  : Colors.black87)
                              : (isDark ? Colors.white38 : Colors.black45),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Chart Display
        Expanded(
          child: filteredLogs.isEmpty
              ? Center(
                  child: Text(
                    'No data logs in this range',
                    style: TextStyle(
                        color: isDark ? Colors.white30 : Colors.black38,
                        fontSize: 13),
                  ),
                )
              : LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor:
                            isDark ? const Color(0xFF14171A) : Colors.white,
                        tooltipBorder: BorderSide(
                          color: const Color(0xFF00FF88).withValues(alpha: 0.5),
                          width: 1,
                        ),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((LineBarSpot touchedSpot) {
                            final index = touchedSpot.x.toInt();
                            if (index < 0 || index >= filteredLogs.length) {
                              return null;
                            }
                            final log = filteredLogs[index];
                            final timeStr =
                                DateFormat('HH:mm:ss').format(log.timestamp);
                            return LineTooltipItem(
                              '$timeStr\n',
                              TextStyle(
                                color: isDark ? Colors.white60 : Colors.black54,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: 'LVL: ${log.batteryLevel}%\n',
                                  style: const TextStyle(
                                    color: Color(0xFF00FF88),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                TextSpan(
                                  text: 'V: ${log.voltage ?? 12.0} V',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 20,
                      verticalInterval: max(1.0, filteredLogs.length / 5.0),
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: isDark ? Colors.white10 : Colors.black12,
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: isDark ? Colors.white10 : Colors.black12,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 25,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}',
                              style: TextStyle(
                                color: isDark ? Colors.white38 : Colors.black38,
                                fontSize: 9,
                                fontFamily: 'monospace',
                              ),
                            );
                          },
                          reservedSize: 22,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: max(1.0, filteredLogs.length / 4.0),
                          getTitlesWidget: (value, meta) {
                            final int index = value.toInt();
                            if (index < 0 || index >= filteredLogs.length) {
                              return const SizedBox.shrink();
                            }
                            final log = filteredLogs[index];
                            final timeStr =
                                DateFormat('HH:mm').format(log.timestamp);
                            return Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                timeStr,
                                style: TextStyle(
                                  color:
                                      isDark ? Colors.white38 : Colors.black38,
                                  fontSize: 8,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            );
                          },
                          reservedSize: 20,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(
                            color: isDark ? Colors.white10 : Colors.black12,
                            width: 1),
                        left: BorderSide(
                            color: isDark ? Colors.white10 : Colors.black12,
                            width: 1),
                      ),
                    ),
                    minX: 0,
                    maxX: (filteredLogs.length - 1).toDouble(),
                    minY: 0,
                    maxY: 100,
                    lineBarsData: [
                      LineChartBarData(
                        spots: filteredLogs.asMap().entries.map((entry) {
                          return FlSpot(entry.key.toDouble(),
                              entry.value.batteryLevel.toDouble());
                        }).toList(),
                        isCurved: true,
                        color: const Color(0xFF00FF88),
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) =>
                              FlDotCirclePainter(
                            radius: 3,
                            color: const Color(0xFF14171A),
                            strokeColor: const Color(0xFF00FF88),
                            strokeWidth: 1.5,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFF00FF88).withValues(alpha: 0.08),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
