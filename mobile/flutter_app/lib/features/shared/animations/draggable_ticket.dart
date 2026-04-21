import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../../../../core/utils/haptic_utils.dart';

class DraggableTicket extends StatefulWidget {
  final Widget child;
  const DraggableTicket({super.key, required this.child});

  @override
  State<DraggableTicket> createState() => _DraggableTicketState();
}

class _DraggableTicketState extends State<DraggableTicket> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    
    _controller.addListener(() {
      setState(() {
        _dragOffset = _animation.value;
      });
    });
  }

  void _runSpringAnimation(Offset pixelsPerSecond, Size size) {
    _animation = _controller.drive(
      Tween<Offset>(
        begin: _dragOffset,
        end: Offset.zero,
      ),
    );

    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, -pixelsPerSecond.distance / size.width);
    _controller.animateWith(simulation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return GestureDetector(
      onPanDown: (details) {
        _controller.stop();
      },
      onPanUpdate: (details) {
        setState(() {
          _dragOffset += details.delta;
        });
      },
      onPanEnd: (details) {
        HapticUtils.heavyImpact();
        _runSpringAnimation(details.velocity.pixelsPerSecond, size);
      },
      child: Transform.translate(
        offset: _dragOffset,
        child: widget.child,
      ),
    );
  }
}
