import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class HologramTicket extends StatefulWidget {
  final Widget child;
  const HologramTicket({Key? key, required this.child}) : super(key: key);

  @override
  State<HologramTicket> createState() => _HologramTicketState();
}

class _HologramTicketState extends State<HologramTicket> {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  double _xRatio = 0.5;
  double _yRatio = 0.5;

  @override
  void initState() {
    super.initState();
    _accelerometerSubscription =
        accelerometerEventStream().listen((AccelerometerEvent event) {
      // Normalize accelerometer roughly from -10..10 to 0..1
      setState(() {
        _xRatio = ((event.x + 10) / 20).clamp(0.0, 1.0);
        _yRatio = ((event.y + 10) / 20).clamp(0.0, 1.0);
      });
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          widget.child,
          // Holographic overlay
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: FractionalOffset(_xRatio * 2 - 0.5, _yRatio * 2 - 0.5),
                  end: FractionalOffset(1.0 - _xRatio, 1.0 - _yRatio),
                  colors: [
                    Colors.white.withAlpha((0.0 * 255).round()),
                    Colors.white.withAlpha((0.4 * 255).round()),
                    Colors.purpleAccent.withAlpha((0.2 * 255).round()),
                    Colors.cyanAccent.withAlpha((0.2 * 255).round()),
                    Colors.white.withAlpha((0.0 * 255).round()),
                  ],
                  stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
