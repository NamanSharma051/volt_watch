import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/providers.dart';
import '../../core/services/notification_service.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  final TextEditingController _alertController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _alertController.dispose();
    super.dispose();
  }

  void _addAlertThreshold() {
    if (_formKey.currentState!.validate()) {
      final value = int.parse(_alertController.text.trim());
      if (ref.read(settingsViewModelProvider).uiHaptics) {
        HapticFeedback.lightImpact();
      }
      ref.read(settingsViewModelProvider.notifier).addCustomAlert(value);
      _alertController.clear();
      FocusScope.of(context).unfocus();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added alert threshold at $value%'),
          backgroundColor: const Color(0xFF00FF88),
        ),
      );
    }
  }

  void _triggerTestNotification() async {
    if (ref.read(settingsViewModelProvider).uiHaptics) {
      HapticFeedback.mediumImpact();
    }
    final hasPermission = await NotificationService.requestPermission();
    if (hasPermission) {
      await NotificationService.showNotification(
        id: 999,
        title: 'VoltWatch System Test',
        body: 'Local notifications channel verified successfully.',
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification permission denied by system.'),
            backgroundColor: Color(0xFFFF3B30),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color cardColor = isDark ? const Color(0xFF14171A) : Colors.white;
    final Color borderColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0D0E) : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            const Icon(Icons.notifications_active, color: Color(0xFF00FF88), size: 24),
            const SizedBox(width: 8),
            Text(
              'ALERT CONFIG',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: isDark ? Colors.white70 : appLabelColor(isDark),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Alert Creator Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ADD CUSTOM THRESHOLD',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white38 : Colors.black45),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _alertController,
                            keyboardType: TextInputType.number,
                             style: TextStyle(fontFamily: 'monospace', fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'Enter level (1-100)',
                              hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black38, fontSize: 13),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              filled: true,
                              fillColor: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Color(0xFF00FF88), width: 1.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Color(0xFFFF3B30)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 1.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              final val = int.tryParse(value);
                              if (val == null || val < 1 || val > 100) {
                                return 'Valid range: 1-100';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00FF88),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: _addAlertThreshold,
                            child: const Text('ADD', style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 2. Configured Alerts List
            Text(
              'ACTIVE TELEMETRY ALERTS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: settings.customAlerts.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'No alerts configured.',
                          style: TextStyle(color: isDark ? Colors.white30 : Colors.black38, fontSize: 13),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: settings.customAlerts.length,
                      separatorBuilder: (context, index) => Divider(color: isDark ? Colors.white10 : Colors.black12, height: 1),
                      itemBuilder: (context, index) {
                        final val = settings.customAlerts[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: const Icon(Icons.notifications_active_outlined, color: Color(0xFF00FF88), size: 20),
                          title: Text(
                            'Alert at $val%',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Will send notification when battery hits $val%',
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black54),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Color(0xFFFF3B30), size: 20),
                            onPressed: () {
                              if (settings.uiHaptics) {
                                HapticFeedback.lightImpact();
                              }
                              ref.read(settingsViewModelProvider.notifier).removeCustomAlert(val);
                            },
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 24),

            // 3. Alert History logs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ALERT TRIGGER HISTORY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                if (settings.alertHistory.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      if (settings.uiHaptics) {
                        HapticFeedback.mediumImpact();
                      }
                      ref.read(settingsViewModelProvider.notifier).clearAlertHistory();
                    },
                    child: const Text('Clear', style: TextStyle(color: Color(0xFFFF3B30), fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: settings.alertHistory.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'No alert history logged yet.',
                          style: TextStyle(color: isDark ? Colors.white30 : Colors.black38, fontSize: 13),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: settings.alertHistory.length,
                      itemBuilder: (context, index) {
                        final log = settings.alertHistory[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12, width: 0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, size: 14, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  log,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            
            const SizedBox(height: 24),
            
            // 4. Verification Channel Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.bug_report_outlined, size: 18),
                label: const Text('TRIGGER TEST NOTIFICATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: _triggerTestNotification,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Color appLabelColor(bool isDark) => Colors.black87;
}
