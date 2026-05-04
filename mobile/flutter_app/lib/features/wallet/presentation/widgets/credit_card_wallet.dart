import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../../../../core/utils/haptic_utils.dart';

class CreditCardWallet extends StatefulWidget {
  final String userId;
  final double balance;

  const CreditCardWallet({
    Key? key,
    required this.userId,
    required this.balance,
  }) : super(key: key);

  @override
  State<CreditCardWallet> createState() => _CreditCardWalletState();
}

class _CreditCardWalletState extends State<CreditCardWallet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  Future<void> _flipCard() async {
    HapticUtils.selectionClick();
    if (_isFlipped) {
      _controller.reverse();
      try {
        await ScreenBrightness().resetApplicationScreenBrightness();
      } catch (e) {
        debugPrint('Parlaklık sıfırlanamadı: $e');
      }
    } else {
      _controller.forward();
      try {
        await ScreenBrightness().setApplicationScreenBrightness(1.0);
      } catch (e) {
        debugPrint('Parlaklık fullenemedi: $e');
      }
    }
    _isFlipped = !_isFlipped;
  }

  @override
  void dispose() {
    _controller.dispose();
    try {
      ScreenBrightness().resetApplicationScreenBrightness();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final isFrontVisible = _controller.value < 0.5;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_controller.value * pi);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: isFrontVisible ? _buildFront() : _buildBack(),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withAlpha(102),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'UNI_CARD',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 2.0,
                ),
              ),
              Icon(Icons.contactless,
                  color: Colors.white.withAlpha(204), size: 32),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOPLAM BAKİYE',
                style: TextStyle(
                    color: Colors.white.withAlpha(178), fontSize: 12),
              ),
              Text(
                '${widget.balance} UNV',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
            ],
          ),
          Text(
            widget.userId,
            style: TextStyle(
              color: Colors.white.withAlpha(204),
              fontSize: 16,
              letterSpacing: 4.0,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBack() {
    final theme = Theme.of(context);
    // Rotating back visually because the matrix flip makes it upside down
    return Transform(
      transform: Matrix4.rotationX(pi),
      alignment: Alignment.center,
      child: Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: theme.colorScheme.surface,
          border: Border.all(
              color: theme.colorScheme.primary.withAlpha(128), width: 2),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withAlpha(51),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: QrImageView(
              data: widget.userId,
              version: QrVersions.auto,
              size: 150.0,
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
