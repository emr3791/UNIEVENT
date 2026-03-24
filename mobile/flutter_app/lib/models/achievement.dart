class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final DateTime unlockedDate;
  final int progress; // 0-100
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlockedDate,
    this.progress = 0,
    this.isUnlocked = false,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      unlockedDate:
          DateTime.parse(json['unlockedDate'] ?? DateTime.now().toString()),
      progress: json['progress'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
    );
  }
}
