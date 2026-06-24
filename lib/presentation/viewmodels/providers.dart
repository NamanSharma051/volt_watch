import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/battery_log.dart';
import '../../data/repositories/battery_repository.dart';
import '../../data/repositories/battery_repository_impl.dart';
import 'battery_viewmodel.dart';
import 'settings_viewmodel.dart';

final logBoxProvider = Provider<Box<BatteryLog>>((ref) {
  throw UnimplementedError();
});

final settingsBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError();
});

final batteryRepositoryProvider = Provider<BatteryRepository>((ref) {
  final logBox = ref.watch(logBoxProvider);
  final settingsBox = ref.watch(settingsBoxProvider);
  return BatteryRepositoryImpl(logBox, settingsBox);
});

final batteryViewModelProvider = StateNotifierProvider<BatteryViewModel, BatteryState>((ref) {
  final repository = ref.watch(batteryRepositoryProvider);
  return BatteryViewModel(repository);
});

final settingsViewModelProvider = StateNotifierProvider<SettingsViewModel, SettingsState>((ref) {
  final repository = ref.watch(batteryRepositoryProvider);
  return SettingsViewModel(repository);
});
