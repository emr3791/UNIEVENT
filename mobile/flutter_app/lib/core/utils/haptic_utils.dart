import 'package:flutter/services.dart';

class HapticUtils {
  /// Hafif dokunuş hissi. (Light impact)
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Orta seviye dokunuş hissi. (Medium impact)
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Ağır dokunuş hissi. (Heavy impact)
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Seçim değişimi efekti. (Kaydırmalar vb.)
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }
}
