import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../data/models/event_model.dart';
import '../widgets/event_card.dart';

class ArRadarPage extends StatefulWidget {
  const ArRadarPage({super.key});

  @override
  State<ArRadarPage> createState() => _ArRadarPageState();
}

class _ArRadarPageState extends State<ArRadarPage> {
  StreamSubscription<GyroscopeEvent>? _gyroSubscription;
  double _xOffset = 0.0;
  double _yOffset = 0.0;

  @override
  void initState() {
    super.initState();
    // Simulate AR floating by tracking device rotation
    _gyroSubscription = gyroscopeEventStream().listen((GyroscopeEvent event) {
      setState(() {
        _xOffset += event.y * 10;
        _yOffset += event.x * 10;
        
        // Clamp boundaries
        _xOffset = _xOffset.clamp(-300.0, 300.0);
        _yOffset = _yOffset.clamp(-400.0, 400.0);
      });
    });
  }

  @override
  void dispose() {
    _gyroSubscription?.cancel();
    super.dispose();
  }

  void _onPinTapped(EventModel event) {
    HapticUtils.mediumImpact();
    // Show mini card
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: SizedBox(
          height: 480,
          child: EventCard(event: event),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('AR Kampüs Lensi', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Simulated Camera Background
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?q=80&w=800&auto=format&fit=crop', // university campus
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),

          // AR Floating Elements
          Positioned(
            left: (size.width / 2) - 80 + _xOffset,
            top: (size.height / 2) - 100 + _yOffset,
            child: _buildArPin(mockEvents[0], "150m"),
          ),
          
          Positioned(
            left: (size.width / 2) + 60 + (_xOffset * 0.5),
            top: (size.height / 2) + 100 + (_yOffset * 0.5),
            child: _buildArPin(mockEvents[1], "300m"),
          ),
          
          Positioned(
            left: (size.width / 2) - 150 + (_xOffset * 1.5),
            top: (size.height / 2) - 200 + (_yOffset * 1.5),
            child: _buildArPin(mockEvents[2], "50m"),
          ),

          // Radar Scan Line Overlay
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _RadarOverlayPainter(theme.primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArPin(EventModel event, String distance) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _onPinTapped(event),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.primaryColor.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ]
            ),
            child: Column(
              children: [
                Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                ),
                Text(
                  distance,
                  style: TextStyle(color: theme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          Container(
            width: 2,
            height: 40,
            color: theme.primaryColor,
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(blurRadius: 10, color: theme.primaryColor, spreadRadius: 5)
              ]
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarOverlayPainter extends CustomPainter {
  final Color color;
  _RadarOverlayPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw some techy crosshairs
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
    
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 100, paint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 200, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
