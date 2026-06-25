import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/datasources/battery_local_datasource.dart';
import '../../data/models/battery_log.dart';
import '../../data/repositories/battery_repository.dart';
import '../../data/repositories/battery_repository_impl.dart';
import 'battery_viewmodel.dart';
import 'settings_viewmodel.dart';

// ── Hive Box Providers (overridden in main.dart via ProviderScope) ─────────
final logBoxProvider = Provider<Box<BatteryLog>>((ref) {
  throw UnimplementedError(
      'logBoxProvider must be overridden in ProviderScope');
});

final settingsBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError(
      'settingsBoxProvider must be overridden in ProviderScope');
});

// ── Data Layer: Datasource → Repository ───────────────────────────────────
final batteryLocalDatasourceProvider = Provider<BatteryLocalDatasource>((ref) {
  return BatteryLocalDatasource(
    logBox: ref.watch(logBoxProvider),
    settingsBox: ref.watch(settingsBoxProvider),
  );
});

final batteryRepositoryProvider = Provider<BatteryRepository>((ref) {
  return BatteryRepositoryImpl(ref.watch(batteryLocalDatasourceProvider));
});

// ── Presentation Layer: ViewModels ────────────────────────────────────────
final batteryViewModelProvider =
    StateNotifierProvider<BatteryViewModel, BatteryState>((ref) {
  return BatteryViewModel(ref.watch(batteryRepositoryProvider));
});

final settingsViewModelProvider =
    StateNotifierProvider<SettingsViewModel, SettingsState>((ref) {
  return SettingsViewModel(ref.watch(batteryRepositoryProvider));
});
