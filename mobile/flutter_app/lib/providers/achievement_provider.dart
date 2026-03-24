import 'package:flutter/material.dart';
import '../models/achievement.dart';

class AchievementProvider with ChangeNotifier {
  final List<Achievement> _achievements = [
    Achievement(
      id: 'first_event',
      title: 'İlk Adım',
      description: 'İlk etkinliğine katıl',
      icon: '🎉',
      unlockedDate: DateTime.now(),
      isUnlocked: false,
      progress: 0,
    ),
    Achievement(
      id: 'five_events',
      title: '5 Etkinlik',
      description: '5 etkinliğe katıl',
      icon: '⭐',
      unlockedDate: DateTime.now(),
      isUnlocked: false,
      progress: 20,
    ),
    Achievement(
      id: 'favorite_100',
      title: 'Favori Koleksiyoncusu',
      description: '10 etkinliği favorilere ekle',
      icon: '❤️',
      unlockedDate: DateTime.now(),
      isUnlocked: false,
      progress: 30,
    ),
    Achievement(
      id: 'social_butterfly',
      title: 'Sosyal Kelebek',
      description: 'Etkinliği 5 kişiye paylaş',
      icon: '🦋',
      unlockedDate: DateTime.now(),
      isUnlocked: false,
      progress: 0,
    ),
    Achievement(
      id: 'early_bird',
      title: 'Erken Kuş',
      description: 'Etkinliğine zamanında katıl',
      icon: '🐦',
      unlockedDate: DateTime.now(),
      isUnlocked: false,
      progress: 40,
    ),
  ];

  List<Achievement> get achievements => _achievements;

  List<Achievement> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();

  int get totalAchievements => _achievements.length;
  int get unlockedCount => unlockedAchievements.length;

  void unlockAchievement(String achievementId) {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index != -1 && !_achievements[index].isUnlocked) {
      _achievements[index] = Achievement(
        id: _achievements[index].id,
        title: _achievements[index].title,
        description: _achievements[index].description,
        icon: _achievements[index].icon,
        unlockedDate: DateTime.now(),
        isUnlocked: true,
        progress: 100,
      );
      notifyListeners();
    }
  }

  void updateProgress(String achievementId, int progress) {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index != -1 && progress <= 100) {
      _achievements[index] = Achievement(
        id: _achievements[index].id,
        title: _achievements[index].title,
        description: _achievements[index].description,
        icon: _achievements[index].icon,
        unlockedDate: _achievements[index].unlockedDate,
        isUnlocked: _achievements[index].isUnlocked,
        progress: progress,
      );
      notifyListeners();
    }
  }

  bool isAchievementUnlocked(String achievementId) {
    return _achievements
        .firstWhere(
          (a) => a.id == achievementId,
          orElse: () => Achievement(
            id: '',
            title: '',
            description: '',
            icon: '',
            unlockedDate: DateTime.now(),
          ),
        )
        .isUnlocked;
  }
}
