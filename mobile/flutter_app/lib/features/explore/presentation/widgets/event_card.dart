import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/theme_provider.dart';
import '../../../../providers/wallet_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/event_provider.dart';
import '../../../../providers/event_chat_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/event_model.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final canAccess = event.canAccess(themeProvider.universityCode);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(76),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        image: DecorationImage(
          image: NetworkImage(event.imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withAlpha(102),
            BlendMode.darken,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Glass info panel at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  color: theme.scaffoldBackgroundColor.withAlpha(178),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: theme.textTheme.displayLarge
                                  ?.copyWith(fontSize: 22),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildAccessBadge(canAccess, theme),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.locationName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondaryDark,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: canAccess
                              ? () async {
                                  final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            title:
                                                const Text('Etkinliğe Katıl'),
                                            content: Text(
                                                '${event.title} etkinliğine katılmak istediğinizden emin misiniz?'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: const Text('Hayır')),
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  child: const Text('Evet')),
                                            ],
                                          ));
                                  if (confirmed != true) return;
                                  if (!context.mounted) return;

                                  final wallet = Provider.of<WalletProvider>(
                                      context,
                                      listen: false);
                                  final auth = Provider.of<AuthProvider>(
                                      context,
                                      listen: false);
                                  final eventProv = Provider.of<EventProvider>(
                                      context,
                                      listen: false);
                                  final chatProv =
                                      Provider.of<EventChatProvider>(context,
                                          listen: false);
                                  final price = event.price;
                                  if (price <= 0) {
                                    // Free join
                                    eventProv.joinEvent(event.id);
                                    chatProv.joinEvent(event.id, event.title,
                                        auth.currentUser?.id ?? 'guest');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Etkinliğe katıldınız')));
                                    return;
                                  }

                                  final success = wallet.purchase(price);
                                  if (success) {
                                    eventProv.joinEvent(event.id);
                                    chatProv.joinEvent(event.id, event.title,
                                        auth.currentUser?.id ?? 'guest');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Bilet satın alındı. ${price.toStringAsFixed(0)} UNV düşüldü.')));
                                  } else {
                                    // Not enough balance: prompt user to buy UNV via Kart Bilgilerim
                                    showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              title:
                                                  const Text('Yetersiz Bakiye'),
                                              content: const Text(
                                                  'Cüzdan bakiyeniz yetersiz. Kart Bilgilerim sayfasından UNV satın alabilirsiniz.'),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text('İptal')),
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      Navigator.of(context)
                                                          .pushNamed(
                                                              '/personal_info');
                                                    },
                                                    child: const Text(
                                                        'Kart Bilgilerim')),
                                              ],
                                            ));
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canAccess
                                ? theme.primaryColor
                                : Colors.grey.withAlpha(76),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: canAccess ? 8 : 0,
                            shadowColor: canAccess
                                ? theme.primaryColor.withAlpha(128)
                                : Colors.transparent,
                          ),
                          child: Text(
                            canAccess
                                ? (event.price == 0
                                    ? 'Ücretsiz Bilet Al'
                                    : '${event.price.toStringAsFixed(0)} UNV - Bilet Al')
                                : 'Erişime Kapalı',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Type Badge Top Left
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: event.isPublic
                      ? AppColors.secondaryNeon.withAlpha(204)
                      : theme.primaryColor.withAlpha(204),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (event.isPublic
                              ? AppColors.secondaryNeon
                              : theme.primaryColor)
                          .withAlpha(128),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]),
              child: Text(
                event.isPublic
                    ? 'Genel Katılıma Açık'
                    : 'Sadece ${event.targetUniversityCode}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAccessBadge(bool canAccess, ThemeData theme) {
    if (canAccess) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.green.withAlpha(51),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_circle_outline,
            color: Colors.green, size: 20),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.red.withAlpha(51),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.lock_outline, color: Colors.red, size: 20),
      );
    }
  }
}
