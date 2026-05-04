import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../providers/achievement_provider.dart';
import '../widgets/avatar_widget.dart';
import '../models/user.dart';

// navigation destinations and helpers
import 'chat_screen.dart';
import 'favorites_screen.dart';
import 'my_events_screen.dart';
import 'achievements_screen.dart';
import '../utils/animation_utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;
          return SingleChildScrollView(
            child: Column(
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      AvatarWidget(
                        user: user ??
                            User(
                              id: 'guest',
                              email: '',
                              username: '',
                              fullName: 'Kullanıcı',
                              userType: 'regular',
                            ),
                        size: 80,
                        showBorder: true,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.fullName ?? user?.username ?? 'User',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        tileColor: Colors.white.withAlpha(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: const Text(
                          'Kişisel Bilgilerim',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                            'Gizli bilgilerinizi burada güvenli bir şekilde yönetin.'),
                        trailing: Icon(Icons.chevron_right,
                            color: Colors.white.withAlpha(153)),
                        onTap: () {
                          Navigator.pushNamed(context, '/personal_info');
                        },
                      ),
                      const SizedBox(height: 24),

                      // Quick Links
                      const Text(
                        'Hızlı Bağlantılar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                AnimationUtils.slideLeftTransition(
                                  const ChatScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              side: const BorderSide(
                                  color: Color(0xFF6366F1), width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              '💬 Sohbet',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Consumer<EventProvider>(
                            builder: (c, ep, _) => ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  AnimationUtils.slideLeftTransition(
                                    const FavoritesScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                side: const BorderSide(
                                    color: Color(0xFF6366F1), width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                '❤️ ${ep.favoriteEvents.length} Favori',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Consumer<EventProvider>(
                            builder: (c, ep, _) => ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  AnimationUtils.slideLeftTransition(
                                    const MyEventsScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                side: const BorderSide(
                                    color: Color(0xFF6366F1), width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                '📅 ${ep.myEvents.length} Katıldığım',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Consumer<AchievementProvider>(
                            builder: (c, ap, _) => ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  AnimationUtils.slideLeftTransition(
                                    const AchievementsScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                side: const BorderSide(
                                    color: Color(0xFF6366F1), width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                '🏆 ${ap.unlockedCount}/${ap.totalAchievements}',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
