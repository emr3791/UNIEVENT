import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../widgets/event_card.dart';
import '../models/event.dart';
import '../utils/animation_utils.dart';
import 'event_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final List<Event> favorites = eventProvider.favoriteEvents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorilerim'),
        backgroundColor: const Color(0xFF6366F1),
      ),
      body: favorites.isEmpty
          ? Center(
              child: Text(
                'Henüz favori etkinliğiniz yok',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final event = favorites[index];
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
                    onBuyTap: () {},
                  ),
                );
              },
            ),
    );
  }
}
