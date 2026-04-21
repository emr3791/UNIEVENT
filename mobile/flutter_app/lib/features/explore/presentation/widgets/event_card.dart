import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/theme_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/event_model.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

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
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        image: DecorationImage(
          image: NetworkImage(event.imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.4),
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
                  color: theme.scaffoldBackgroundColor.withOpacity(0.7),
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
                              style: theme.textTheme.displayLarge?.copyWith(fontSize: 22),
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
                          onPressed: canAccess ? () {} : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canAccess ? theme.primaryColor : Colors.grey.withOpacity(0.3),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: canAccess ? 8 : 0,
                            shadowColor: canAccess ? theme.primaryColor.withOpacity(0.5) : Colors.transparent,
                          ),
                          child: Text(
                            canAccess 
                                ? (event.price == 0 ? 'Ücretsiz Bilet Al' : '${event.price} TL - Bilet Al')
                                : 'Erişime Kapalı',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                color: event.isPublic ? AppColors.secondaryNeon.withOpacity(0.8) : theme.primaryColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (event.isPublic ? AppColors.secondaryNeon : theme.primaryColor).withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              ),
              child: Text(
                event.isPublic ? 'Genel Katılıma Açık' : 'Sadece ${event.targetUniversityCode}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
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
          color: Colors.green.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.lock_outline, color: Colors.red, size: 20),
      );
    }
  }
}
