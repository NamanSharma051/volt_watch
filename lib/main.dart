import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/services/background_service.dart';
import 'core/services/notification_service.dart';
import 'data/models/battery_log.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/viewmodels/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Hive — if boxes are corrupted from a previous install, wipe and recreate
  await Hive.initFlutter();
  Hive.registerAdapter(BatteryLogAdapter());

  late Box<BatteryLog> logBox;
  late Box settingsBox;
  try {
    logBox = await Hive.openBox<BatteryLog>(AppConstants.batteryBoxName);
    settingsBox = await Hive.openBox(AppConstants.settingsBoxName);
  } catch (e) {
    debugPrint('Hive box corrupted, resetting: $e');
    await Hive.deleteBoxFromDisk(AppConstants.batteryBoxName);
    await Hive.deleteBoxFromDisk(AppConstants.settingsBoxName);
    logBox = await Hive.openBox<BatteryLog>(AppConstants.batteryBoxName);
    settingsBox = await Hive.openBox(AppConstants.settingsBoxName);
  }

  // Notifications and background tasks — wrapped in try-catch so a WorkManager
  // failure (common on MIUI / ColorOS / aggressive battery optimisation) never
  // crashes the app before Flutter draws its first frame.
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    try {
      await NotificationService.init();
    } catch (e) {
      debugPrint('NotificationService init failed (non-fatal): $e');
    }
    try {
      await BackgroundService.init();
      await BackgroundService.registerPeriodicTask();
    } catch (e) {
      debugPrint('BackgroundService init failed (non-fatal): $e');
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        logBoxProvider.overrideWithValue(logBox),
        settingsBoxProvider.overrideWithValue(settingsBox),
      ],
      child: const VoltWatchApp(),
    ),
  );
}

class VoltWatchApp extends ConsumerWidget {
  const VoltWatchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsViewModelProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const MainScreen(),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
