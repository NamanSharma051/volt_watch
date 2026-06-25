import 'package:hive/hive.dart';

part 'battery_log.g.dart';

@HiveType(typeId: 0)
class BatteryLog extends HiveObject {
  @HiveField(0)
  final int batteryLevel;

  @HiveField(1)
  final String batteryState;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final double? voltage;

  @HiveField(4)
  final double? current;

  @HiveField(5)
  final double? temperature;

  BatteryLog({
    required this.batteryLevel,
    required this.batteryState,
    required this.timestamp,
    this.voltage,
    this.current,
    this.temperature,
  });

  Map<String, dynamic> toJson() {
    return {
      'batteryLevel': batteryLevel,
      'batteryState': batteryState,
      'timestamp': timestamp.toIso8601String(),
      'voltage': voltage,
      'current': current,
      'temperature': temperature,
    };
  }

  factory BatteryLog.fromJson(Map<String, dynamic> json) {
    return BatteryLog(
      batteryLevel: json['batteryLevel'],
      batteryState: json['batteryState'],
      timestamp: DateTime.parse(json['timestamp']),
      voltage: json['voltage']?.toDouble(),
      current: json['current']?.toDouble(),
      temperature: json['temperature']?.toDouble(),
    );
  }
}
