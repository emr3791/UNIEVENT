import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../../../../core/utils/haptic_utils.dart';

class PhysicsButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoration;
  
  const PhysicsButton({
    super.key, 
    required this.child, 
    required this.onPressed,
    this.padding,
    this.decoration,
  });

  @override
  State<PhysicsButton> createState() => _PhysicsButtonState();
}

class _PhysicsButtonState extends State<PhysicsButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late SpringSimulation _springSim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, 
        lowerBound: 0.0, 
        upperBound: 1.0,
        value: 1.0);
        
    _springSim = SpringSimulation(
      const SpringDescription(mass: 1.0, stiffness: 400.0, damping: 15.0),
      0.0,
      1.0,
      0.0,
    );
  }

  void _onTapDown(TapDownDetails details) {
    HapticUtils.lightImpact();
    // Start compressing the button
    _controller.animateTo(0.9, duration: const Duration(milliseconds: 50), curve: Curves.easeOutCubic);
  }

  void _onTapUp(TapUpDetails details) {
    HapticUtils.mediumImpact();
    // Release with physics spring effect
    _controller.animateWith(_springSim);
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.animateWith(_springSim);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _controller.value,
            child: child,
          );
        },
        child: Container(
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: widget.decoration ?? BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              )
            ]
          ),
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
