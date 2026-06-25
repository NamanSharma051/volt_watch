import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ConsumptionChart extends StatelessWidget {
  final List<double> consumptionValues;

  const ConsumptionChart({super.key, required this.consumptionValues});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use default values if empty
    final displayValues = consumptionValues.isNotEmpty
        ? consumptionValues
        : [1.2, 2.4, 1.8, 3.5, 5.1, 4.2, 5.8, 2.1];

    final maxVal = displayValues.isEmpty
        ? 8.0
        : displayValues.reduce((a, b) => a > b ? a : b);
    final computedMaxY = maxVal > 8.0 ? maxVal * 1.15 : 8.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        minY: 0,
        maxY: computedMaxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: isDark ? const Color(0xFF14171A) : Colors.white,
            tooltipBorder: BorderSide(
                color: const Color(0xFF00FF88).withValues(alpha: 0.5), width: 1),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toStringAsFixed(1)} W',
                const TextStyle(
                  color: Color(0xFF00FF88),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              );
            },
          ),
        ),
        titlesData: const FlTitlesData(
          show: false, // Clean telemetry look without axes
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark ? Colors.white10 : Colors.black12,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: displayValues.asMap().entries.map((entry) {
          final index = entry.key;
          final val = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: val,
                color: const Color(0xFF00FF88),
                width: 12,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3),
                  topRight: Radius.circular(3),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
