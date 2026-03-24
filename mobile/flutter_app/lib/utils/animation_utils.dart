import 'package:flutter/material.dart';

class AnimationUtils {
  // Slide Transition from left
  static Route<dynamic> slideLeftTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  // Slide Transition from right
  static Route<dynamic> slideRightTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  // Fade Transition
  static Route<dynamic> fadeTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  // Scale Transition with Fade
  static Route<dynamic> scaleTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(scale: animation, child: child);
      },
    );
  }

  // Bounce Animation Widget
  static Widget bounceAnimation({
    required Widget child,
    required AnimationController controller,
  }) {
    final animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: controller, curve: Curves.bounceOut),
    );
    return ScaleTransition(scale: animation, child: child);
  }

  // Pulse Animation (opacity)
  static Widget pulseAnimation({
    required Widget child,
    required AnimationController controller,
  }) {
    final animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
    return FadeTransition(opacity: animation, child: child);
  }

  // Slide Up From Bottom
  static Route<dynamic> slideUpTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  // Rotate and Scale Animation
  static Route<dynamic> rotateScaleTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return Transform.scale(
          scale: animation.value,
          child: Transform.rotate(
            angle: animation.value * 0.5,
            child: child,
          ),
        );
      },
    );
  }
}
