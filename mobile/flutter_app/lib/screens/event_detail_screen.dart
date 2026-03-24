import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/app_drawer.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy HH:mm', 'tr_TR');
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Etkinlik Detayları'),
        backgroundColor: const Color(0xFF6366F1),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[200],
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    event.imageUrl ?? 'https://via.placeholder.com/400x250',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF6366F1).withOpacity(0.2),
                        child: const Icon(
                          Icons.event,
                          size: 80,
                          color: Color(0xFF6366F1),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(event.category),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getCategoryLabel(event.category),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Rating and Attendees
                  if (event.attendees != null)
                    Row(
                      children: [
                        Icon(Icons.people, size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          '${event.attendees} kişi katılacak',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Info Cards
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.calendar_today,
                          label: 'Tarih & Saat',
                          value: dateFormat.format(event.date),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.location_on,
                          label: 'Yer',
                          value: event.location,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.school,
                          label: 'Üniversite',
                          value: event.university,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.place,
                          label: 'Şehir',
                          value: event.city,
                        ),
                        if (event.speaker != null) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.person,
                            label: 'Konuşmacı',
                            value: event.speaker!,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Etkinlik Hakkında',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      height: 1.6,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Price and Button
                  if (event.price != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fiyat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Bilet Fiyatı',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                '₺${event.price!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Consumer<EventProvider>(
                          builder: (context, eventProvider, _) {
                            final isFavorite =
                                eventProvider.isFavorite(event.id);
                            return OutlinedButton.icon(
                              onPressed: () {
                                eventProvider.toggleFavorite(event.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isFavorite
                                        ? 'Favorilerden çıkarıldı'
                                        : 'Favorilere eklendi'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              icon: Icon(isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border),
                              label:
                                  Text(isFavorite ? 'Favorilerde' : 'Favori'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isFavorite
                                    ? Colors.red
                                    : const Color(0xFF6366F1),
                                side: BorderSide(
                                    color: isFavorite
                                        ? Colors.red
                                        : const Color(0xFF6366F1)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Consumer<EventProvider>(
                          builder: (context, eventProvider, _) {
                            final restrictionMessage = eventProvider
                                .joinRestrictionMessage(event, user);
                            final isJoined = eventProvider.isJoined(event.id);
                            final canJoin = restrictionMessage == null;

                            return ElevatedButton.icon(
                              onPressed: canJoin
                                  ? () {
                                      if (isJoined) {
                                        eventProvider.unjoinEvent(event.id);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Etkinlikten ayrıldınız'),
                                              backgroundColor: Colors.orange),
                                        );
                                      } else {
                                        eventProvider.joinEvent(event.id);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text('Etkinliğe katıldınız'),
                                              backgroundColor: Colors.green),
                                        );
                                      }
                                    }
                                  : null,
                              icon: Icon(isJoined ? Icons.check : Icons.add),
                              label: Text(isJoined ? 'Ayrıl' : 'Katıl'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isJoined
                                    ? Colors.orange
                                    : const Color(0xFF6366F1),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Consumer2<EventProvider, NotificationProvider>(
                          builder: (context, eventProvider,
                              notificationProvider, _) {
                            final isReminder =
                                eventProvider.isReminderSet(event.id);
                            return OutlinedButton.icon(
                              onPressed: () {
                                eventProvider.toggleReminder(event.id);
                                if (!isReminder) {
                                  final daysLeft = event.date
                                      .difference(DateTime.now())
                                      .inDays;
                                  final reminderContent = daysLeft > 0
                                      ? '$daysLeft gün sonra bu etkinlik gerçekleşecek! Katılmak istiyorsan yerini ayırtmayı unutma.'
                                      : 'Bu etkinlik çok yakında gerçekleşecek! Katılmak istiyorsan acele et.';

                                  notificationProvider.addNotification(
                                    title: 'Hatırlatma Kuruldu',
                                    message: reminderContent,
                                    type: NotificationType.reminder,
                                  );
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isReminder
                                        ? 'Hatırlatıcı iptal edildi'
                                        : 'Hatırlatıcı ayarlandı'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              icon: Icon(isReminder
                                  ? Icons.notifications_off
                                  : Icons.notifications_active),
                              label: Text(isReminder
                                  ? 'Hatırlatmayı Kapat'
                                  : 'Hatırlat'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isReminder
                                    ? Colors.grey[800]
                                    : const Color(0xFF6366F1),
                                side: BorderSide(
                                  color: isReminder
                                      ? Colors.grey
                                      : const Color(0xFF6366F1),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: const Color(0xFF6366F1),
                        child: IconButton(
                          icon: const Icon(Icons.share, color: Colors.white),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Paylaşım linki kopyalandı'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Join restriction note
                  Consumer<EventProvider>(
                    builder: (context, eventProvider, _) {
                      final restrictionMessage =
                          eventProvider.joinRestrictionMessage(event, user);
                      if (restrictionMessage == null) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.red.withOpacity(0.2)),
                        ),
                        child: Text(
                          restrictionMessage,
                          style:
                              TextStyle(color: Colors.red[800], fontSize: 12),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Additional Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.blue[200] ?? Colors.blue),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Colors.blue, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            event.isOpenToExternal
                                ? 'Bu etkinlik dışarıdan katılıma açıktır'
                                : 'Bu etkinlik sadece İç katılımcılara açıktır',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6366F1), size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'concerts':
        return Colors.red;
      case 'seminars':
        return Colors.blue;
      case 'news':
        return Colors.green;
      case 'events':
        return Colors.orange;
      default:
        return const Color(0xFF6366F1);
    }
  }

  String _getCategoryLabel(String category) {
    switch (category.toLowerCase()) {
      case 'concerts':
        return 'Konser';
      case 'seminars':
        return 'Seminer';
      case 'news':
        return 'Haber';
      case 'events':
        return 'Etkinlik';
      default:
        return category;
    }
  }
}
