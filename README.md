# VoltWatch

A Flutter app for monitoring battery health in real time. It tracks your charge level, logs history over time, sends alerts when you hit a threshold you care about, and keeps doing all of that even after you close the app.

---

## ⚡ Quick Start for Evaluators

There are **two ways** to run this — pick whichever is easier for you.

### Option A — Install the APK directly (no Flutter needed)

> Best if you just want to see the app running on an Android device.

1. Download **`volt_watch.apk`** from the [Releases](https://github.com/NamanSharma051/volt_watch/releases/latest) page of this repo.
2. Transfer it to your Android phone (USB or any file-sharing method).
3. On the phone: enable **Install from unknown sources** (Settings → Security → Install unknown apps).
4. Tap the APK file to install and open VoltWatch.

> ⚠️ Minimum Android version: **Android 8.0 (API 26)**. The app will not install on older devices.

---

### Option B — Build and run from source

> Best if you want to review the code running live on a device/emulator.

**Prerequisites:**
| Tool | Version | Download |
|------|---------|----------|
| Flutter SDK | 3.x (tested on 3.44.3) | [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install) |
| JDK | 17 | [adoptium.net](https://adoptium.net/) |
| Android SDK | API 34 | Comes with Android Studio |
| Android device or emulator | Android 8.0+ | — |

**Steps:**

```bash
# 1. Clone the repo
git clone https://github.com/NamanSharma051/volt_watch.git
cd volt_watch

# 2. Install dependencies
flutter pub get

# 3. Generate Hive adapters (required — the app won't compile without this)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Connect an Android device (or start an emulator), then run
flutter run
```

> **Windows only:** If step 2 fails with a symlink error, go to Settings → Privacy & Security → Developer Mode and turn it on. This is a Flutter-on-Windows requirement, not specific to this project.

**Verify the setup worked:**
```bash
flutter doctor   # should show no critical errors
flutter devices  # should show your connected device or emulator
```

---

## How the code is structured

```
lib/
├── core/
│   ├── constants/        → app_constants.dart  (Hive box names, setting keys, color values)
│   ├── services/         → background_service.dart, notification_service.dart
│   └── utils/            → battery_estimator.dart, kalman_filter.dart
│
├── data/
│   ├── datasources/      → battery_local_datasource.dart  (all raw Hive reads/writes live here)
│   ├── models/           → battery_log.dart + generated adapter
│   └── repositories/     → abstract interface + impl that delegates to the datasource
│
├── presentation/
│   ├── screens/          → dashboard, analytics, alerts, settings, main shell
│   ├── viewmodels/       → BatteryViewModel, SettingsViewModel, providers
│   └── widgets/          → battery gauge, charts
│
└── main.dart
```

I kept the layers strict on purpose. The ViewModels never touch Hive directly — they only call the repository interface. The datasource is where the actual `box.get` / `box.put` calls happen. That way if I ever want to swap Hive for SQLite or Isar, I only touch one file.

Riverpod wires everything together through `providers.dart`:
`BatteryLocalDatasource` → `BatteryRepositoryImpl` → `BatteryViewModel` / `SettingsViewModel` → UI

---

## What it does

**Dashboard** — the main screen shows a custom-painted animated gauge that changes colour as your battery drains (green above 80%, yellow between 40–79%, red below 40%). Below the gauge there's a live telemetry strip with voltage, current draw, wattage and temperature. If your phone is charging, it shows a rough estimate of time to full based on the current charge rate.

**Analytics** — every 15 minutes the app logs your battery level and charging state to a local Hive database. The analytics screen plots this on a line chart (using fl_chart) with Live / 1H / 24H filter modes. You can also scroll through the raw log table underneath. Pull to refresh to force a sync.

**Alerts** — you can add as many percentage thresholds as you want (e.g. notify me at 80%, notify me at 20%). When the battery hits any of them, a local notification fires. The test button at the bottom lets you verify your notification channel is working before you rely on it.

**Settings** — dark/light theme toggle (persisted), polling interval (1s / 5s / 15s), predictive smoothing via a Kalman filter, haptic feedback controls, and a "clear all logs" option. There are also quick-switch charging profiles that adjust polling and smoothing together.

---

## Why I picked these libraries

**Hive** for storage — I looked at SharedPreferences and SQLite but Hive made more sense here. For time-series data where you're appending a record every 15 minutes and reading back a list, Hive's binary format is noticeably faster than SQLite, and there's no schema migration to worry about. SharedPreferences handles the simple scalar settings (threshold value, theme preference) since that's exactly what it's designed for.

**Riverpod** for state — I went with `StateNotifier` over `ChangeNotifier` / `Provider` because it makes the state immutable and forces you to be deliberate about updates. Using `.select()` on the consumers means only the widget that actually uses a given field rebuilds when that field changes — which keeps the 1-second battery polling from causing the entire widget tree to redraw every second.

**WorkManager** for background — it's the Android-recommended way to schedule periodic work that survives app termination. I registered a task with `NetworkType.notRequired` so it runs purely on device, no connectivity dependency. On web the background task falls back to a simple in-app timer since there's no equivalent browser API without a service worker.

**flutter_local_notifications** — I deliberately don't ask for notification permission on launch. The permission prompt only appears when you actually add your first alert threshold or tap the test button. In my experience apps that ask for permissions up front before you've given the user any reason to care get denied a lot more often.

---

## Stuff that took a while to figure out

**Name collision with battery_plus.** My own state class is called `BatteryState` and so is the enum in the `battery_plus` package. The compiler was happy about it until I imported both in the same file, then it got confused. Fixed it with `import 'package:battery_plus/battery_plus.dart' as bp;` and referenced the package type as `bp.BatteryState` everywhere. Obvious in hindsight, annoying to debug at the time.

**Web crashes with no useful error.** When I first ran it on Chrome I got a red screen with `Null check operator used on a null value` pointing at some enum `.name` call. The issue is that `dart2js` (the Web compiler) is stricter about dynamic types than the native Dart VM. A `final state = ref.watch(...)` that works fine on Android fails on web because the type is inferred as `dynamic`. I went through and explicitly typed every state variable in `build()` methods and pre-computed any string values in the state class rather than calling `.name` on enums in the widget.

**Settings screen crash after reset.** The "Reset to Defaults" button was calling `setThreshold(80)` — which made sense if 80% was the alert threshold, but the slider on the settings screen has a range of 5–30 (it's a critical-low threshold, not a custom alert). 80 is way outside that range so Flutter threw an assertion. I fixed the default to 15, and added a `.clamp(5, 30)` in both the datasource and the viewmodel so even if a bad value somehow gets into Hive, it gets corrected before it ever reaches the slider.

**ListTile inside a Container with BoxDecoration.** Flutter throws a warning when a `ListTile` or `SwitchListTile` sits inside a widget with a background colour set via `BoxDecoration` — the tile paints its ink effects on the nearest `Material` ancestor, which gets hidden behind the `DecoratedBox`. Adding `tileColor` on the tile doesn't actually fix it. The real fix is replacing the `Container` + `BoxDecoration` with `ClipRRect` + `Material` as the parent, which gives the tiles a proper Material surface to paint on.

---

## Known limitations

- **Web / battery data**: Browsers don't expose raw battery hardware (voltage, current, wattage) via any public API, and even the basic Battery Status API is disabled in most browsers for fingerprinting reasons. On web the telemetry values are simulated. On Android they come from the actual hardware.
- **iOS**: The app targets Android primarily. iOS would need a developer account for physical device testing, and the BGTaskScheduler background API works differently enough that it'd need its own implementation. The code has the platform guards in place but I haven't tested it on a real iPhone.
- **Background on web**: There's no WorkManager equivalent for the browser. Closing the tab stops everything. A proper solution would need a service worker, which is out of scope here.

---

## Dependencies

```yaml
battery_plus: ^6.2.3
flutter_riverpod: ^2.6.1
hive_flutter: ^1.1.0
workmanager: ^0.9.0+3
flutter_local_notifications: ^17.2.4
fl_chart: ^0.66.2
```
