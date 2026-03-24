import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/user.dart';
import '../services/event_service.dart';

class EventProvider with ChangeNotifier {
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;

  // Favorites & Engagement
  final List<String> _favoriteEventIds = [];
  final List<String> _joinedEventIds = [];
  final Map<String, int> _eventParticipants = {};

  // Reminder feature: events user asked to be reminded about
  final Set<String> _reminderEventIds = {};

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get favorites => _favoriteEventIds;
  List<String> get joinedEvents => _joinedEventIds;

  List<Event> get favoriteEvents {
    return _events.where((e) => _favoriteEventIds.contains(e.id)).toList();
  }

  List<Event> get myEvents {
    return _events.where((e) => _joinedEventIds.contains(e.id)).toList();
  }

  final EventService _eventService = EventService();

  Future<void> loadEvents({String host = '192.168.0.100'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _events = await _eventService.fetchEvents(host: host);
      // Initialize participant counts
      for (var event in _events) {
        _eventParticipants[event.id] = (20 + _events.indexOf(event) * 5) % 100;
      }
    } catch (e) {
      _error = e.toString();
      _events = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Event> getPersonalizedEvents(String city, List<String> interests) {
    return _events.where((event) {
      return event.city == city && interests.contains(event.category);
    }).toList();
  }

  // Favorites Management
  void toggleFavorite(String eventId) {
    if (_favoriteEventIds.contains(eventId)) {
      _favoriteEventIds.remove(eventId);
    } else {
      _favoriteEventIds.add(eventId);
    }
    notifyListeners();
  }

  bool isFavorite(String eventId) {
    return _favoriteEventIds.contains(eventId);
  }

  // Join/Unjoin Events
  bool canJoinEvent(Event event, User? user) {
    if (event.isOpenToExternal) return true;
    if (user == null) return false;
    if (user.userType != 'student') return false;
    if (user.university == null || user.university!.isEmpty) return false;
    return user.university!.toLowerCase().trim() ==
        event.university.toLowerCase().trim();
  }

  String? joinRestrictionMessage(Event event, User? user) {
    if (event.isOpenToExternal) return null;
    if (user == null) return 'Lütfen giriş yapın';
    if (user.userType != 'student') {
      return 'Bu etkinlik yalnızca üniversite öğrencilerine açıktır';
    }
    if (user.university == null || user.university!.isEmpty) {
      return 'Üniversite bilgisi eksik';
    }
    if (user.university!.toLowerCase().trim() !=
        event.university.toLowerCase().trim()) {
      return 'Bu etkinlik yalnızca ${event.university} öğrencilerine açıktır';
    }
    return null;
  }

  void joinEvent(String eventId) {
    if (!_joinedEventIds.contains(eventId)) {
      _joinedEventIds.add(eventId);
      _eventParticipants[eventId] = (_eventParticipants[eventId] ?? 0) + 1;
      notifyListeners();
    }
  }

  void unjoinEvent(String eventId) {
    if (_joinedEventIds.contains(eventId)) {
      _joinedEventIds.remove(eventId);
      _eventParticipants[eventId] = (_eventParticipants[eventId] ?? 0) - 1;
      notifyListeners();
    }
  }

  bool isJoined(String eventId) {
    return _joinedEventIds.contains(eventId);
  }

  bool isReminderSet(String eventId) {
    return _reminderEventIds.contains(eventId);
  }

  void toggleReminder(String eventId) {
    if (_reminderEventIds.contains(eventId)) {
      _reminderEventIds.remove(eventId);
    } else {
      _reminderEventIds.add(eventId);
    }
    notifyListeners();
  }

  int getParticipantCount(String eventId) {
    return _eventParticipants[eventId] ?? 0;
  }

  // Get Upcoming Events
  List<Event> getUpcomingEvents() {
    final now = DateTime.now();
    return _events.where((e) => e.date.isAfter(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}
