import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/utils/haptic_utils.dart';

class ShatterCard extends StatefulWidget {
  final Widget child;
  final bool isShattered;
  
  const ShatterCard({
    Key? key,
    required this.child,
    this.isShattered = false,
  }) : super(key: key);

  @override
  State<ShatterCard> createState() => _ShatterCardState();
}

class _ShatterCardState extends State<ShatterCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    if (widget.isShattered) {
      _triggerShatter();
    }
  }

  @override
  void didUpdateWidget(ShatterCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShattered && !oldWidget.isShattered) {
      _triggerShatter();
    } else if (!widget.isShattered && oldWidget.isShattered) {
      _controller.reverse();
    }
  }

  void _triggerShatter() {
    HapticUtils.heavyImpact();
    _controller.forward(from: 0.0);
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
        if (_controller.value == 0) return widget.child;
        
        return CustomPaint(
          foregroundPainter: _ShatterPainter(_controller.value),
          child: Opacity(
            opacity: 1.0 - (_controller.value * 1.5).clamp(0.0, 1.0),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _ShatterPainter extends CustomPainter {
  final double progress;
  _ShatterPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = Colors.grey.withAlpha(((1 - progress) * 255).round().clamp(0, 255))
      ..style = PaintingStyle.fill;

    final random = math.Random(42); // Seed for consistent shatter pattern
    const int pieces = 12;

    for (int i = 0; i < pieces; i++) {
      final dx = (random.nextDouble() - 0.5) * size.width * progress * 2;
      final dy = (random.nextDouble() - 0.5) * size.height * progress * 2 + (progress * 100); // Gravity effect
      final rotation = (random.nextDouble() - 0.5) * math.pi * progress * 4;
      
      final basePath = Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 4, 0)
        ..lineTo(size.width / 8, size.height / 4)
        ..close();

      canvas.save();
      // Move to random fragment origin
      canvas.translate(
        (size.width / 2) + dx, 
        (size.height / 2) + dy
      );
      canvas.rotate(rotation);
      
      canvas.drawPath(basePath, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ShatterPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
