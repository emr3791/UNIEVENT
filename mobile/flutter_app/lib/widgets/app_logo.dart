import 'package:flutter/material.dart';

class AppLogo extends StatefulWidget {
  final double size;
  final bool showText;
  final Color? color;

  const AppLogo({
    Key? key,
    this.size = 64,
    this.showText = true,
    this.color,
  }) : super(key: key);

  @override
  State<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animation.value),
              child: child,
            );
          },
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Purple 'U' facing UP (Now Black if primary not defined, wait, no, the first U is white!)
                Positioned(
                  bottom: widget.size * 0.15,
                  child: Text(
                    'U',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.size * 0.9,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 4),
                          blurRadius: 8,
                          color: Colors.black.withAlpha((0.3 * 255).round()),
                        ),
                      ],
                    ),
                  ),
                ),
                // Black 'U' facing DOWN (using Rotation)
                Positioned(
                  top: widget.size * 0.15,
                  child: Transform.rotate(
                    angle: 3.14159, // 180 degrees in radians
                    child: Text(
                      'U',
                      style: TextStyle(
                        color: Colors.black87, // Mor yerine siyah
                        fontSize: widget.size * 0.9,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        shadows: [
                          Shadow(
                            offset: const Offset(0,
                                4), // Shadow reversed because text is flipped
                            blurRadius: 8,
                            color: Colors.black.withAlpha((0.3 * 255).round()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.showText) ...[
          const SizedBox(height: 12),
          Text(
            'UniEvent AI',
            style: TextStyle(
              fontSize: widget.size * 0.35,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ],
    );
  }
}
