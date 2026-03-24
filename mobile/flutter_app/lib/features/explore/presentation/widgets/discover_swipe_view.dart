import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../../data/models/event_model.dart';
import 'event_card.dart';
import '../../../../core/utils/haptic_utils.dart';

class DiscoverSwipeView extends StatefulWidget {
  const DiscoverSwipeView({Key? key}) : super(key: key);

  @override
  State<DiscoverSwipeView> createState() => _DiscoverSwipeViewState();
}

class _DiscoverSwipeViewState extends State<DiscoverSwipeView> {
  final CardSwiperController _controller = CardSwiperController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    if (direction == CardSwiperDirection.right) {
      HapticUtils.heavyImpact();
      // Like / Save logic
    } else if (direction == CardSwiperDirection.left) {
      HapticUtils.lightImpact();
      // Discard logic
    }
    return true; // Return true to allow the swipe
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: CardSwiper(
        controller: _controller,
        cardsCount: mockEvents.length,
        onSwipe: _onSwipe,
        allowedSwipeDirection: const AllowedSwipeDirection.symmetric(
          horizontal: true,
          vertical: false, // Only Tinder left-right logic
        ),
        padding: const EdgeInsets.all(24.0),
        cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
          final event = mockEvents[index];
          // Adding a physics based wrap to the card
          return EventCard(event: event);
        },
      ),
    );
  }
}
