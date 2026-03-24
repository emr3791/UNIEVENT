import 'package:flutter/material.dart';
import 'dart:math' as math;

class CubicPageTransition extends PageRouteBuilder {
  final Widget page;

  CubicPageTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                // Determine slide / cube angle
                final angle = (1 - animation.value) * math.pi / 2;
                
                // Matrix 4x4 perspective definition
                final transform = Matrix4.identity()
                  ..setEntry(3, 2, 0.002) // Perspective depth
                  ..rotateY(-angle);
                  
                return Transform(
                  transform: transform,
                  alignment: Alignment.centerRight,
                  child: Opacity(
                    opacity: animation.value,
                    child: child,
                  ),
                );
              },
              child: child,
            );
          },
        );
}
