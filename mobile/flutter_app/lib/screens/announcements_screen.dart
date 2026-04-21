import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../widgets/event_card.dart';
import '../utils/animation_utils.dart';
import 'event_detail_screen.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final announcements = eventProvider.events
        .where((event) => event.category.toLowerCase() == 'news')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Duyurular'),
        backgroundColor: const Color(0xFF6366F1),
      ),
      body: announcements.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Henüz bir duyuru yok. Yeni bir duyuru olduğunda burada görünecek.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: announcements.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final event = announcements[index];
                return EventCard(
                  event: event,
                  participantCount: eventProvider.getParticipantCount(event.id),
                  onTap: () {
                    Navigator.of(context).push(
                      AnimationUtils.slideLeftTransition(
                        EventDetailScreen(event: event),
                      ),
                    );
                  },
                  onBuyTap: () {
                    // Announcements don't have ticket purchases.
                  },
                );
              },
            ),
    );
  }
}
