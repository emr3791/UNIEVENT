import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../widgets/event_card.dart';
import '../models/event.dart';
import '../utils/animation_utils.dart';
import 'event_detail_screen.dart';

class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final List<Event> myEvents = eventProvider.myEvents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katıldığım Etkinlikler'),
        backgroundColor: const Color(0xFF6366F1),
      ),
      body: myEvents.isEmpty
          ? Center(
              child: Text(
                'Henüz katıldığınız etkinlik yok',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myEvents.length,
              itemBuilder: (context, index) {
                final event = myEvents[index];
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
