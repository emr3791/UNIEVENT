import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/reusable_banner.dart';
import '../providers/event_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/event_chat_provider.dart';
import '../models/event.dart';
import '../widgets/event_card.dart';
import '../widgets/app_drawer.dart';
import '../utils/animation_utils.dart';
import 'event_chat_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'announcements_screen.dart';
import 'event_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Seçilen index'e göre body'yi değiştir
    Widget bodyWidget;
    AppBar? appBar;

    if (_selectedIndex == 0) {
      bodyWidget = const HomeContent();
      appBar = AppBar(
        title: const Text('UniEventAI'),
        centerTitle: true,
        backgroundColor: const Color(0xFF6366F1),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _selectedIndex = 1;
              });
            },
          ),
        ],
      );
    } else if (_selectedIndex == 1) {
      bodyWidget = const SearchScreen();
      appBar = AppBar(
        title: const Text('Ara'),
        backgroundColor: const Color(0xFF6366F1),
        elevation: 0,
      );
    } else if (_selectedIndex == 2) {
      bodyWidget = const AnnouncementsScreen();
      appBar = AppBar(
        title: const Text('Duyurular'),
        backgroundColor: const Color(0xFF6366F1),
        elevation: 0,
      );
    } else {
      bodyWidget = const ProfileScreen();
      appBar = AppBar(
        title: const Text('Profil'),
        backgroundColor: const Color(0xFF6366F1),
        elevation: 0,
      );
    }

    return Scaffold(
      appBar: appBar,
      drawer: const AppDrawer(),
      body: bodyWidget,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.colorScheme.surface,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Ara',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Duyurular',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor:
              theme.colorScheme.onSurface.withAlpha((0.4 * 255).round()),
          showUnselectedLabels: true,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.normal, fontSize: 11),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _showWelcomeBanner = true;
  late Future<void> _loadFuture;
  late final ScrollController _scrollController;
  final GlobalKey _eventsSectionKey = GlobalKey();
  String _selectedCategory = 'all';
  final List<Map<String, dynamic>> categories = [
    {
      'id': 'all',
      'title': 'Tüm Etkinlikler',
      'icon': Icons.category,
      'color': const Color(0xFF6366F1),
    },
    {
      'id': 'news',
      'title': 'Haberler',
      'icon': Icons.newspaper,
      'color': Colors.green,
    },
    {
      'id': 'concerts',
      'title': 'Konserler',
      'icon': Icons.music_note,
      'color': Colors.red,
    },
    {
      'id': 'seminars',
      'title': 'Seminerler',
      'icon': Icons.school,
      'color': Colors.blue,
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    final provider = Provider.of<EventProvider>(context, listen: false);
    _loadFuture = provider.loadEvents();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _selectCategory(String categoryId) {
    setState(() => _selectedCategory = categoryId);
    // Scroll to the events section so users see the filtered list.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_eventsSectionKey.currentContext != null) {
        Scrollable.ensureVisible(
          _eventsSectionKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  String _getCategoryLabel(String category) {
    switch (category.toLowerCase()) {
      case 'news':
        return 'Haberler';
      case 'concerts':
        return 'Konserler';
      case 'seminars':
        return 'Seminerler';
      case 'all':
        return 'Tüm Etkinlikler';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header (reusable banner)
          if (_showWelcomeBanner)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ReusableBanner(
                icon: Icons.waving_hand,
                title:
                    'Hoş geldiniz, ${authProvider.currentUser?.fullName ?? "Kullanıcı"}!',
                subtitle: 'Üniversite etkinliklerini keşfetmeye ne dersiniz?',
                actionLabel: 'Kapat',
                onAction: () => setState(() => _showWelcomeBanner = false),
              ),
            ),
          const SizedBox(height: 16),

          // Announcements Section
          Consumer<EventProvider>(
            builder: (context, eventProvider, _) {
              final announcements = eventProvider.events
                  .where((e) => e.category.toLowerCase() == 'news')
                  .take(3)
                  .toList();
              if (announcements.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      '🔥 Önemli Duyurular',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: announcements.length,
                      itemBuilder: (context, index) {
                        final announcement = announcements[index];
                        return Container(
                          width: 280,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.shade400,
                                Colors.deepOrange
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange
                                    .withAlpha((0.3 * 255).round()),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.of(context).push(
                                  AnimationUtils.slideLeftTransition(
                                    EventDetailScreen(event: announcement),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.onPrimary
                                            .withAlpha((0.15 * 255).round()),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'YENİ',
                                        style: TextStyle(
                                          color: theme.colorScheme.onPrimary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      announcement.title,
                                      style: TextStyle(
                                        color: theme.colorScheme.onPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),

          // Animated Stacked Category Cards
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = _selectedCategory == category['id'];
                final color = category['color'] as Color;
                return GestureDetector(
                  onTap: () => _selectCategory(category['id']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 130,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Back card 2
                          Positioned(
                            top: 4,
                            left: 8,
                            right: 0,
                            child: Container(
                              height: 130,
                              width: 115,
                              decoration: BoxDecoration(
                                color: color.withAlpha((0.2 * 255).round()),
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                          // Back card 1
                          Positioned(
                            top: 4,
                            left: 4,
                            right: 4,
                            child: Container(
                              height: 130,
                              width: 110,
                              decoration: BoxDecoration(
                                color: color.withAlpha((0.4 * 255).round()),
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                          // Front card
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isSelected
                                    ? [
                                        color,
                                        color.withAlpha((0.7 * 255).round())
                                      ]
                                    : [
                                        color.withAlpha((0.85 * 255).round()),
                                        color.withAlpha((0.6 * 255).round())
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withAlpha(
                                      ((isSelected ? 0.5 : 0.2) * 255).round()),
                                  blurRadius: isSelected ? 16 : 8,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedScale(
                                  scale: isSelected ? 1.15 : 1.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.onPrimary
                                          .withAlpha((0.18 * 255).round()),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      category['icon'] as IconData,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  category['title'] as String,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    width: 24,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Active Category Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _selectedCategory == 'all'
                  ? 'Tüm Etkinlikler'
                  : 'Kategori: ${_getCategoryLabel(_selectedCategory)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Upcoming events (filtered by selected category)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Consumer<EventProvider>(
              builder: (context, eventProvider, _) {
                final upcomingEvents = eventProvider
                    .getUpcomingEvents()
                    .where((event) => _selectedCategory == 'all'
                        ? true
                        : event.category.toLowerCase() == _selectedCategory)
                    .take(3)
                    .toList();
                return upcomingEvents.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Seçili kategoride yaklaşan etkinlik yok',
                            style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withAlpha((0.7 * 255).round())),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: upcomingEvents.length,
                        itemBuilder: (context, index) {
                          final event = upcomingEvents[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withAlpha(13),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color:
                                        const Color(0xFF6366F1).withAlpha(51)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      color: Color(0xFF6366F1), size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${event.date.day}/${event.date.month}/${event.date.year}',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Consumer<EventProvider>(
                                    builder: (context, eventProvider, _) {
                                      final isJoined =
                                          eventProvider.isJoined(event.id);
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (isJoined)
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.chat_bubble,
                                                  color: Color(0xFF6366F1),
                                                  size: 20),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              tooltip: 'Etkinlik Sohbeti',
                                              onPressed: () {
                                                final chatProvider = Provider
                                                    .of<EventChatProvider>(
                                                        context,
                                                        listen: false);
                                                final authUser =
                                                    Provider.of<AuthProvider>(
                                                            context,
                                                            listen: false)
                                                        .currentUser;
                                                chatProvider.joinEvent(
                                                    event.id,
                                                    event.title,
                                                    authUser?.id ?? 'guest');
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          EventChatScreen(
                                                              eventId: event.id,
                                                              eventTitle:
                                                                  event.title),
                                                    ));
                                              },
                                            ),
                                          const SizedBox(width: 4),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (isJoined) {
                                                eventProvider
                                                    .unjoinEvent(event.id);
                                              } else {
                                                eventProvider
                                                    .joinEvent(event.id);
                                                // Ensure event chat is created and user added
                                                final chatProv = Provider.of<
                                                        EventChatProvider>(
                                                    context,
                                                    listen: false);
                                                final authUser =
                                                    Provider.of<AuthProvider>(
                                                            context,
                                                            listen: false)
                                                        .currentUser;
                                                chatProv.joinEvent(
                                                    event.id,
                                                    event.title,
                                                    authUser?.id ?? 'guest');
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isJoined
                                                  ? Colors.orange
                                                  : const Color(0xFF6366F1),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                            ),
                                            child: Text(
                                              isJoined ? 'Katıldı' : 'Katıl',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Events Section
          Padding(
            key: _eventsSectionKey,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Text(
              'Etkinlikler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FutureBuilder<void>(
              future: _loadFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    eventProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6366F1),
                    ),
                  );
                }

                if (eventProvider.error != null) {
                  return ReusableBanner(
                    icon: Icons.error_outline,
                    title: 'Etkinlikler yüklenemedi',
                    subtitle: eventProvider.error ?? 'Bilinmeyen hata',
                    actionLabel: 'Yenile',
                    onAction: () => eventProvider.loadEvents(),
                  );
                }

                List<Event> displayedEvents = eventProvider.events;

                if (_selectedCategory != 'all') {
                  displayedEvents = displayedEvents
                      .where(
                        (event) =>
                            event.category.toLowerCase() == _selectedCategory,
                      )
                      .toList();
                }

                if (displayedEvents.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Bu kategoride etkinlik bulunamadı',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayedEvents.length,
                  itemBuilder: (context, index) {
                    final event = displayedEvents[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: EventCard(
                        event: event,
                        participantCount:
                            eventProvider.getParticipantCount(event.id),
                        onTap: () {
                          Navigator.of(context).push(
                            AnimationUtils.slideLeftTransition(
                              EventDetailScreen(event: event),
                            ),
                          );
                        },
                        onBuyTap: () {
                          Navigator.pushNamed(
                            context,
                            '/payment',
                            arguments: event,
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
