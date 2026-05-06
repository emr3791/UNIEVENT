import 'package:flutter/material.dart';
import '../models/achievement.dart';

// This file has been optimized
// unlockedDate is now nullable!

class AchievementProvider with ChangeNotifier {
  final List<Achievement> _achievements = [
    Achievement(
      id: 'first_event',
      title: 'İlk Adım',
      description: 'İlk etkinliğine katıl',
      icon: '🎉',
      unlockedDate: null,
      isUnlocked: false,
      progress: 0,
    ),
    Achievement(
      id: 'five_events',
      title: '5 Etkinlik',
      description: '5 etkinliğe katıl',
      icon: '⭐',
      unlockedDate: null,
      isUnlocked: false,
      progress: 20,
    ),
    Achievement(
      id: 'favorite_100',
      title: 'Favori Koleksiyoncusu',
      description: '10 etkinliği favorilere ekle',
      icon: '❤️',
      unlockedDate: null,
      isUnlocked: false,
      progress: 30,
    ),
    Achievement(
      id: 'social_butterfly',
      title: 'Sosyal Kelebek',
      description: 'Etkinliği 5 kişiye paylaş',
      icon: '🦋',
      unlockedDate: null,
      isUnlocked: false,
      progress: 0,
    ),
    Achievement(
      id: 'early_bird',
      title: 'Erken Kuş',
      description: 'Etkinliğine zamanında katıl',
      icon: '🐦',
      unlockedDate: null,
      isUnlocked: false,
      progress: 40,
    ),
  ];

  List<Achievement> get achievements => _achievements;

  List<Achievement> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();

  int get totalAchievements => _achievements.length;

  // Counts directly without creating an intermediate list
  int get unlockedCount => _achievements.where((a) => a.isUnlocked).length;

  void unlockAchievement(String achievementId) {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index != -1 && !_achievements[index].isUnlocked) {
      _achievements[index] = _achievements[index].copyWith(
        isUnlocked: true,
        progress: 100,
        unlockedDate: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void updateProgress(String achievementId, int progress) {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    // Also guard against updating an already unlocked achievement
    if (index != -1 &&
        !_achievements[index].isUnlocked &&
        progress <= 100) {
      _achievements[index] = _achievements[index].copyWith(progress: progress);
      notifyListeners();
    }
  }

  bool isAchievementUnlocked(String achievementId) {
    try {
      return _achievements.firstWhere((a) => a.id == achievementId).isUnlocked;
    } catch (_) {
      return false;
    }
  }
}