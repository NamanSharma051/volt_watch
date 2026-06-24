import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color cardColor = isDark ? const Color(0xFF14171A) : Colors.white;
    final Color borderColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);
    final Color primaryColor = const Color(0xFF00FF88);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0D0E) : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            const Icon(Icons.settings, color: Color(0xFF00FF88), size: 24),
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
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        children: [
          // Screen Title / Description
          const Text(
            'Advanced Configuration',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Modify core telemetry parameters and interface behaviors. Changes applied here affect immediate system readout metrics.',
            style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black54),
          ),
          const SizedBox(height: 24),

          // 1. BATTERY THRESHOLDS
          _buildSectionHeader('BATTERY THRESHOLDS', isDark),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Critical Alert Threshold', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${settings.threshold}.0%',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red, fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: settings.threshold.toDouble(),
                  min: 5.0,
                  max: 30.0,
                  divisions: 25,
                  activeColor: Colors.red,
                  inactiveColor: isDark ? Colors.white10 : Colors.black12,
                  onChanged: (val) {
                    final newVal = val.round();
                    if (newVal != settings.threshold) {
                      if (settings.uiHaptics) {
                        HapticFeedback.selectionClick();
                      }
                      ref.read(settingsViewModelProvider.notifier).setThreshold(newVal);
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('5%', style: TextStyle(fontSize: 10, color: isDark ? Colors.white24 : Colors.black38)),
                    Text('30%', style: TextStyle(fontSize: 10, color: isDark ? Colors.white24 : Colors.black38)),
                  ],
                ),
                Divider(color: isDark ? Colors.white10 : Colors.black12, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Warning Threshold Offset', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        Text('Delta above critical level', style: TextStyle(fontSize: 11, color: isDark ? Colors.white24 : Colors.black38)),
                      ],
                    ),
                    Container(
                      width: 70,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                      ),
                      child: DropdownButton<int>(
                        value: settings.warningOffset,
                        underline: const SizedBox.shrink(),
                        icon: const Icon(Icons.arrow_drop_down, size: 16),
                        style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                        dropdownColor: cardColor,
                        onChanged: (val) {
                          if (val != null) {
                            if (settings.uiHaptics) {
                              HapticFeedback.lightImpact();
                            }
                            ref.read(settingsViewModelProvider.notifier).setWarningOffset(val);
                          }
                        },
                        items: [5, 10, 15, 20].map((offset) {
                          return DropdownMenuItem<int>(
                            value: offset,
                            child: Text('$offset %'),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. REAL-TIME TELEMETRY
          _buildSectionHeader('REAL-TIME TELEMETRY', isDark),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Data Polling Interval', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                      ),
                      child: DropdownButton<double>(
                        value: settings.pollingInterval,
                        underline: const SizedBox.shrink(),
                        icon: const Icon(Icons.arrow_drop_down, size: 18),
                        style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87, fontSize: 12),
                        dropdownColor: cardColor,
                        onChanged: (val) {
                          if (val != null) {
                            if (settings.uiHaptics) {
                              HapticFeedback.lightImpact();
                            }
                            ref.read(batteryViewModelProvider.notifier).updatePollingInterval(val);
                            ref.read(settingsViewModelProvider.notifier).setPollingInterval(val);
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: 1.0, child: Text('1.0 s (Standard)')),
                          DropdownMenuItem(value: 5.0, child: Text('5.0 s (Telemetry)')),
                          DropdownMenuItem(value: 15.0, child: Text('15.0 s (Battery Saver)')),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(color: isDark ? Colors.white10 : Colors.black12, height: 24),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Predictive Smoothing', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text('Apply Kalman filter to voltage spikes', style: TextStyle(fontSize: 11, color: isDark ? Colors.white24 : Colors.black38)),
                  value: settings.predictiveSmoothing,
                  activeColor: primaryColor,
                  onChanged: (val) {
                    if (settings.uiHaptics) {
                      HapticFeedback.lightImpact();
                    }
                    ref.read(settingsViewModelProvider.notifier).togglePredictiveSmoothing(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. INTERFACE
          _buildSectionHeader('INTERFACE', isDark),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode Theme', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  value: settings.isDarkMode,
                  activeColor: primaryColor,
                  onChanged: (val) {
                    if (settings.uiHaptics) {
                      HapticFeedback.lightImpact();
                    }
                    ref.read(settingsViewModelProvider.notifier).toggleTheme(val);
                  },
                ),
                Divider(color: isDark ? Colors.white10 : Colors.black12, height: 1),
                SwitchListTile(
                  title: const Text('High Contrast Mode', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  value: settings.highContrastMode,
                  activeColor: primaryColor,
                  onChanged: (val) {
                    if (settings.uiHaptics) {
                      HapticFeedback.lightImpact();
                    }
                    ref.read(settingsViewModelProvider.notifier).toggleHighContrast(val);
                  },
                ),
                Divider(color: isDark ? Colors.white10 : Colors.black12, height: 1),
                SwitchListTile(
                  title: const Text('Absolute Values', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  value: settings.absoluteValues,
                  activeColor: primaryColor,
                  onChanged: (val) {
                    if (settings.uiHaptics) {
                      HapticFeedback.lightImpact();
                    }
                    ref.read(settingsViewModelProvider.notifier).toggleAbsoluteValues(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. HAPTICS
          _buildSectionHeader('HAPTICS', isDark),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Threshold Feedback', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  value: settings.thresholdHaptics,
                  activeColor: primaryColor,
                  onChanged: (val) {
                    if (settings.uiHaptics) {
                      HapticFeedback.lightImpact();
                    }
                    ref.read(settingsViewModelProvider.notifier).toggleThresholdHaptics(val);
                  },
                ),
                Divider(color: isDark ? Colors.white10 : Colors.black12, height: 1),
                SwitchListTile(
                  title: const Text('UI Interactions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  value: settings.uiHaptics,
                  activeColor: primaryColor,
                  onChanged: (val) {
                    HapticFeedback.lightImpact();
                    ref.read(settingsViewModelProvider.notifier).toggleUiHaptics(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 5. System Diagnostics
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_user, color: Color(0xFF00FF88), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'System Diagnostics',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Run a comprehensive test on communication buses, sensor calibration, and memory integrity.',
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black54),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('LAST RUN', style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black45, fontWeight: FontWeight.bold)),
                    Text(
                      settings.diagnosticsLastRun,
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black87, fontFamily: 'monospace'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('STATUS', style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black45, fontWeight: FontWeight.bold)),
                    Text(
                      settings.diagnosticsStatus,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF00FF88), fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: settings.isExecutingDiagnostics
                        ? null
                        : () {
                            if (settings.uiHaptics) {
                              HapticFeedback.mediumImpact();
                            }
                            ref.read(settingsViewModelProvider.notifier).executeDiagnostics();
                          },
                    child: settings.isExecutingDiagnostics
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                          )
                        : const Text('EXECUTE DIAGNOSTICS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 6. ACTIVE PROFILE
          _buildSectionHeader('ACTIVE PROFILE', isDark),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Color(0xFF00FF88), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      settings.activeProfile,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  settings.activeProfile == 'High Performance'
                      ? 'Current configuration favors data granularity over power conservation.'
                      : 'Telemetry frequency is reduced to optimize battery lifetime.',
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black54),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('High Perf', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        selected: settings.activeProfile == 'High Performance',
                        onSelected: (selected) {
                          if (selected) {
                            if (settings.uiHaptics) {
                              HapticFeedback.lightImpact();
                            }
                            ref.read(settingsViewModelProvider.notifier).setActiveProfile('High Performance');
                          }
                        },
                        selectedColor: primaryColor.withOpacity(0.15),
                        checkmarkColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Saver Mode', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        selected: settings.activeProfile == 'Battery Saver',
                        onSelected: (selected) {
                          if (selected) {
                            if (settings.uiHaptics) {
                              HapticFeedback.lightImpact();
                            }
                            ref.read(settingsViewModelProvider.notifier).setActiveProfile('Battery Saver');
                          }
                        },
                        selectedColor: primaryColor.withOpacity(0.15),
                        checkmarkColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ],
                ),
                Divider(color: isDark ? Colors.white10 : Colors.black12, height: 24),
                Center(
                  child: TextButton(
                    onPressed: () {
                      if (settings.uiHaptics) {
                        HapticFeedback.mediumImpact();
                      }
                      ref.read(settingsViewModelProvider.notifier).resetToDefaults();
                    },
                    child: Text(
                      'RESET TO DEFAULTS',
                      style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Divider(height: 48, color: isDark ? Colors.white10 : Colors.black12),
          
          // Clear History Logs Option
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
            title: const Text('Clear All Logs', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            subtitle: const Text('Deletes all persistent database log metrics'),
            onTap: () {
              if (settings.uiHaptics) {
                HapticFeedback.mediumImpact();
              }
              _showClearLogsDialog(context, ref);
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white38 : Colors.black45,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  void _showClearLogsDialog(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsViewModelProvider);
    final isDark = settings.isDarkMode;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF14171A) : Colors.white,
        title: Text('Clear Log Telemetry', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: Text('Are you sure you want to delete all battery metrics history? This action is irreversible.', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
        actions: [
          TextButton(
            onPressed: () {
              if (settings.uiHaptics) {
                HapticFeedback.lightImpact();
              }
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white38 : Colors.black45)),
          ),
          TextButton(
            onPressed: () {
              if (settings.uiHaptics) {
                HapticFeedback.mediumImpact();
              }
              ref.read(batteryViewModelProvider.notifier).clearLogs();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
