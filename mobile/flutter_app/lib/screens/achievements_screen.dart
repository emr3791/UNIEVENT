import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';
import '../models/achievement.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievementProvider = Provider.of<AchievementProvider>(context);
    final List<Achievement> all = achievementProvider.achievements;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Başarılarım'),
        backgroundColor: const Color(0xFF6366F1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: all.length,
          itemBuilder: (context, index) {
            final ach = all[index];
            final unlocked = ach.isUnlocked;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: unlocked
                    ? const Color(0xFF6366F1).withOpacity(0.1)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: unlocked
                      ? const Color(0xFF6366F1)
                      : Colors.grey.withOpacity(0.4),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ach.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ach.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: unlocked ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (!unlocked)
                    Text(
                      'Kilidi açmak için ilerleme: ${ach.progress}%',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
