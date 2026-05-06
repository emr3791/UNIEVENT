// This file has been optimized
// unlockedDate is now nullable!

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final DateTime? unlockedDate; // nullable - only set when actually unlocked
  final int progress; // 0-100
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.unlockedDate, // no longer required
    this.progress = 0,
    this.isUnlocked = false,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    DateTime? unlockedDate,
    int? progress,
    bool? isUnlocked,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      unlockedDate: unlockedDate ?? this.unlockedDate,
      progress: progress ?? this.progress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      unlockedDate: json['unlockedDate'] != null
          ? DateTime.tryParse(json['unlockedDate'])
          : null,
      progress: json['progress'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
    );
  }
}