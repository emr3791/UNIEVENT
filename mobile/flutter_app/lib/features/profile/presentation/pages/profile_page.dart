import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/radar_ping.dart';
import '../../../explore/data/models/event_model.dart';
import '../../../explore/presentation/widgets/event_card.dart';
import '../../../../screens/favorites_screen.dart';
import '../../../../screens/my_events_screen.dart';
import '../../../../screens/achievements_screen.dart';
import '../../../../widgets/avatar_widget.dart';
import '../../../../models/user.dart';
import '../../../../providers/auth_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isRadarMode = false;

  final List<ChatMessage> _chatHistory = [
    ChatMessage(
      text: "Merhaba, kampüste neler oluyor?", 
      sender: MessageSender.me
    ),
    ChatMessage(
      text: "Selam! Bugün ilgini çekebilecek 2 yeni etkinlik var. Özellikle senin bölümüne (TECH) hitap eden bu konferansı kaçırma:", 
      sender: MessageSender.ai
    ),
    ChatMessage(
      text: "",
      sender: MessageSender.ai,
      richWidget: SizedBox(
        height: 380, // Size matched for EventCard
        child: EventCard(event: mockEvents[2]), // Teknoloji Zirvesi
      )
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isRadarMode ? 'Buz Kırıcı Radar' : 'AI Asistan & Profil',
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: Icon(_isRadarMode ? Icons.chat_bubble_outline : Icons.radar),
            onPressed: () {
              setState(() {
                _isRadarMode = !_isRadarMode;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildLegacyProfileHeader(theme),
          Expanded(
            child: _isRadarMode ? _buildRadarMode() : _buildChatMode(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegacyProfileHeader(ThemeData theme) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.5),
            border: Border(
              bottom: BorderSide(color: theme.primaryColor.withOpacity(0.2), width: 1),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Redirect to avatar edit or profile edit
                      Navigator.pushNamed(context, '/personal_info');
                    },
                    child: AvatarWidget(
                      user: user ??
                          User(
                            id: 'guest',
                            email: '',
                            username: '',
                            fullName: 'Misafir Kullanıcı',
                            userType: 'regular',
                          ),
                      size: 60,
                      showBorder: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? user?.username ?? 'Kullanıcı',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          user?.email ?? 'Giriş yapılmadı',
                          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/personal_info');
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text("Düzenle", style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      backgroundColor: theme.primaryColor.withOpacity(0.2),
                      foregroundColor: theme.primaryColor,
                      elevation: 0,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
              // Quick Actions Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildQuickActionBtn(
                      title: "Favoriler", 
                      icon: Icons.favorite, 
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FavoritesScreen()))
                    ),
                    const SizedBox(width: 8),
                    _buildQuickActionBtn(
                      title: "Biletlerim", 
                      icon: Icons.event_available, 
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyEventsScreen()))
                    ),
                    const SizedBox(width: 8),
                    _buildQuickActionBtn(
                      title: "Başarılar", 
                      icon: Icons.emoji_events, 
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AchievementsScreen()))
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionBtn({required String title, required IconData icon, required VoidCallback onTap}) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: Theme.of(context).primaryColor),
      label: Text(title, style: const TextStyle(fontSize: 12)),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3)),
      onPressed: onTap,
    );
  }

  Widget _buildChatMode() {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _chatHistory.length,
            itemBuilder: (context, index) {
              return ChatBubble(message: _chatHistory[index]);
            },
          ),
        ),
        // Chat Input Area (Mock)
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              color: theme.scaffoldBackgroundColor.withOpacity(0.8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Kampüs Asistanına yaz...",
                        style: TextStyle(color: Colors.grey.withOpacity(0.8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: theme.primaryColor,
                    child: const Icon(Icons.send, color: Colors.white),
                  )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 80), // BottomNav padding
      ],
    );
  }

  Widget _buildRadarMode() {
    final theme = Theme.of(context);
    return Center(
      child: RadarPing(
        child: SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Center User
              CircleAvatar(
                radius: 40,
                backgroundColor: theme.colorScheme.surface,
                backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop'),
              ),
              // Dummy nearby users positioned around the radar
              Positioned(
                top: 20,
                left: 50,
                child: _buildRadarUserAvatar('Ali T.'),
              ),
              Positioned(
                bottom: 40,
                right: 30,
                child: _buildRadarUserAvatar('Zeynep K.', isMatches: true),
              ),
              Positioned(
                top: 100,
                right: 20,
                child: _buildRadarUserAvatar('Can R.'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadarUserAvatar(String name, {bool isMatches = false}) {
    final color = isMatches ? Colors.pinkAccent : Theme.of(context).primaryColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ]
          ),
          child: const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
        ),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}
