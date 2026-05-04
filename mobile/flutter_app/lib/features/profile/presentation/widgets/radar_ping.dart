import 'package:flutter/material.dart';
import 'dart:math' as math;

class RadarPing extends StatefulWidget {
  final Widget child;
  const RadarPing({Key? key, required this.child}) : super(key: key);

  @override
  State<RadarPing> createState() => _RadarPingState();
}

class _RadarPingState extends State<RadarPing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _PingPainter(
            progress: _controller.value,
            color: Theme.of(context).primaryColor,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _PingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _PingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;
    
    // Draw 3 expanding rings
    for (int i = 0; i < 3; i++) {
      double currentProgress = (progress + (i * 0.33)) % 1.0;
      double radius = maxRadius * currentProgress;
      double opacity = (1.0 - currentProgress).clamp(0.0, 0.4);

      final paint = Paint()
        ..color = color.withAlpha((opacity * 255).round())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
