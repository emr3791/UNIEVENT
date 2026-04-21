import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ShaderBackground extends StatefulWidget {
  final Widget? child;
  const ShaderBackground({super.key, this.child});

  @override
  State<ShaderBackground> createState() => _ShaderBackgroundState();
}

class _ShaderBackgroundState extends State<ShaderBackground> with SingleTickerProviderStateMixin {
  ui.FragmentShader? _shader;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset('assets/shaders/fluid_wave.frag');
      setState(() {
        _shader = program.fragmentShader();
      });
    } catch (e) {
      debugPrint('Shader yüklenemedi: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_shader == null) {
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Set uniforms: [ResolutionX, ResolutionY, Time, ColorR, ColorG, ColorB]
        final size = MediaQuery.of(context).size;
        _shader!.setFloat(0, size.width);
        _shader!.setFloat(1, size.height);
        _shader!.setFloat(2, _controller.value * 20.0); // Zaman çarpanı
        
        final primaryColor = Theme.of(context).primaryColor;
        _shader!.setFloat(3, primaryColor.red / 255.0);
        _shader!.setFloat(4, primaryColor.green / 255.0);
        _shader!.setFloat(5, primaryColor.blue / 255.0);

        return CustomPaint(
          painter: _ShaderPainter(_shader!),
          child: widget.child,
        );
      },
    );
  }
}

class _ShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;
  _ShaderPainter(this.shader);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..shader = shader;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _ShaderPainter oldDelegate) {
    return true; // Animation based repainting
  }
}
