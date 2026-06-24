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
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(BatteryLogAdapter());
  final logBox = await Hive.openBox<BatteryLog>(AppConstants.batteryBoxName);
  final settingsBox = await Hive.openBox(AppConstants.settingsBoxName);
  
  // Initialize Services
  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
    await NotificationService.init();
    await BackgroundService.init();
    await BackgroundService.registerPeriodicTask();
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
