import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';
import '../models/achievement.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final achievementProvider = Provider.of<AchievementProvider>(context);
    final List<Achievement> all = achievementProvider.achievements;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Başarılarım'),
        backgroundColor: theme.colorScheme.primary,
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
          itemBuilder: (context, index) => _AchievementCard(ach: all[index]),
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement ach;
  const _AchievementCard({required this.ach});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = ach.isUnlocked;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked
            ? theme.colorScheme.primary.withAlpha((0.08 * 255).round())
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unlocked ? theme.colorScheme.primary : theme.dividerColor,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(ach.icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            ach.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: unlocked
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface.withAlpha((0.8 * 255).round()),
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
  }
}