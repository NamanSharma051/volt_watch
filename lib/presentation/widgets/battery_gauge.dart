import 'dart:math';
import 'package:flutter/material.dart';

class BatteryGauge extends StatefulWidget {
  final int level;
  final String status;

  const BatteryGauge({super.key, required this.level, required this.status});

  @override
  State<BatteryGauge> createState() => _BatteryGaugeState();
}

class _BatteryGaugeState extends State<BatteryGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.level / 100).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(BatteryGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level != widget.level) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.level / 100,
      ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateColor = _getBatteryColor(widget.level);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow shadow decoration
                Container(
                  width: 210,
                  height: 210,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: stateColor.withValues(alpha: isDark ? 0.05 : 0.02),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
                CustomPaint(
                  size: const Size(200, 200),
                  painter: _BatteryPainter(
                    progress: _animation.value,
                    color: stateColor,
                    isCharging: widget.status == 'charging',
                    isDark: isDark,
                  ),
                ),
                // Center information overlay
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(widget.level)}%',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        color: isDark ? Colors.white : Colors.black87,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: stateColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: stateColor.withValues(alpha: 0.3), width: 1),
                      ),
                      child: Text(
                        _getStatusLabel(widget.level, widget.status)
                            .toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: stateColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _getStatusLabel(int level, String status) {
    if (status == 'charging') return 'CHARGING';
    if (status == 'full') return 'FULL';
    if (level >= 80) return 'OPTIMIZED';
    if (level >= 40) return 'NOMINAL';
    return 'CRITICAL';
  }

  Color _getBatteryColor(int level) {
    if (level >= 80) return const Color(0xFF00FF88); // Neon Green
    if (level >= 40) return const Color(0xFFFFDD00); // Cyberpunk Yellow
    return const Color(0xFFFF3B30); // Neon Red
  }
}

class _BatteryPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isCharging;
  final bool isDark;

  _BatteryPainter({
    required this.progress,
    required this.color,
    required this.isCharging,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    // Config values
    const outerRingWidth = 2.0;
    const mainArcWidth = 8.0;
    final outerRadius = radius - 2;
    final mainRadius = radius - 15;

    // 1. Outer Ring (thin telemetry ring)
    final outerPaint = Paint()
      ..color = isDark ? Colors.white10 : Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerRingWidth;
    canvas.drawCircle(center, outerRadius, outerPaint);

    // Draw outer progress ticks
    final tickPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw 4 cardinal ticks on outer ring
    for (int i = 0; i < 4; i++) {
      final angle = (i * pi / 2) - pi / 2;
      final start = Offset(
        center.dx + (outerRadius - 4) * cos(angle),
        center.dy + (outerRadius - 4) * sin(angle),
      );
      final end = Offset(
        center.dx + (outerRadius + 2) * cos(angle),
        center.dy + (outerRadius + 2) * sin(angle),
      );
      canvas.drawLine(start, end, tickPaint);
    }

    // 2. Main Track (the path behind the thick arc)
    final trackPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.black.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = mainArcWidth;
    canvas.drawCircle(center, mainRadius, trackPaint);

    // 3. Glowing Progress Arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = mainArcWidth
      ..strokeCap = StrokeCap.round;

    // Outer glow for progress arc (using low opacity thicker line instead of MaskFilter.blur which fails on web)
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = mainArcWidth + 6
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;

    if (sweepAngle > 0.05) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: mainRadius),
        -pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: mainRadius),
        -pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }

    // 4. Charging Bolt Indicator (Visual pulse)
    if (isCharging) {
      final boltColor =
          isDark ? const Color(0xFF00FF88) : const Color(0xFF00C853);
      final boltPaint = Paint()
        ..color = boltColor
        ..style = PaintingStyle.fill;

      // Draw custom vector bolt icon at the top of the ring
      final boltPath = Path();
      final bx = center.dx;
      final by = center.dy - mainRadius;

      boltPath.moveTo(bx + 2, by - 12);
      boltPath.lineTo(bx - 6, by + 1);
      boltPath.lineTo(bx - 1, by + 1);
      boltPath.lineTo(bx - 3, by + 12);
      boltPath.lineTo(bx + 6, by - 1);
      boltPath.lineTo(bx + 1, by - 1);
      boltPath.close();

      // Bolt glow using simple low-opacity outline instead of MaskFilter.blur
      final boltGlow = Paint()
        ..color = boltColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;

      canvas.drawPath(boltPath, boltGlow);
      canvas.drawPath(boltPath, boltPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BatteryPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.isCharging != isCharging ||
        oldDelegate.isDark != isDark;
  }
}
