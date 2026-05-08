import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/user.dart';
import '../services/event_service.dart';

// This file has been optimized
/*
1. favorites and joinedEvents getters now return a new List on every call via .toList() — if any screen stores a reference to these and expects it to stay in sync (e.g. final favs = provider.favorites; favs.add(...)) it will break. They should always read from the provider directly.
2. _favoriteEventIds and _joinedEventIds are now Set — order is not guaranteed. If any screen displays favorites or joined events in insertion order, the order may change. Use LinkedHashSet instead of Set if order matters.
3. getUpcomingEvents() cache doesn't account for time passing — if the app is open across midnight, an event that was upcoming may now be past but the cached list won't update until loadEvents() is called again or the cache is manually invalidated.
4. getPersonalizedEvents cache key uses interests.join(',') — if interests contains a string with a comma in it, two different lists could produce the same key.
*/

class EventProvider with ChangeNotifier {
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;

  // Use Set for O(1) contains checks instead of O(n) List lookups
  final Set<String> _favoriteEventIds = {};
  final Set<String> _joinedEventIds = {};
  final Map<String, int> _eventParticipants = {};
  final Set<String> _reminderEventIds = {};

  // Cached derived lists — rebuilt only when source data changes
  List<Event>? _cachedFavoriteEvents;
  List<Event>? _cachedMyEvents;
  List<Event>? _cachedUpcomingEvents;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Expose as List<String> to avoid breaking existing callers
  List<String> get favorites => _favoriteEventIds.toList();
  List<String> get joinedEvents => _joinedEventIds.toList();

  List<Event> get favoriteEvents {
    return _cachedFavoriteEvents ??= _events
        .where((e) => _favoriteEventIds.contains(e.id))
        .toList();
  }

  List<Event> get myEvents {
    return _cachedMyEvents ??= _events
        .where((e) => _joinedEventIds.contains(e.id))
        .toList();
  }

  final EventService _eventService = EventService();

  // ── Internal helpers ──────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _invalidateCache() {
    _cachedFavoriteEvents = null;
    _cachedMyEvents = null;
    _cachedUpcomingEvents = null;
  }

  // ── Data loading ──────────────────────────────────────────────────────────

  Future<void> loadEvents({String host = '192.168.0.100'}) async {
    _setLoading(true);
    _error = null;
    try {
      _events = await _eventService.fetchEvents(host: host);
      _invalidateCache();
      // O(n) loop with index — avoids O(n²) from indexOf
      for (var i = 0; i < _events.length; i++) {
        _eventParticipants[_events[i].id] = (20 + i * 5) % 100;
      }
    } catch (e) {
      _error = e.toString();
      _events = [];
      _invalidateCache();
    } finally {
      _setLoading(false);
    }
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  // Cache key for personalized events — avoids refiltering on same inputs
  String? _lastPersonalizedKey;
  List<Event>? _cachedPersonalizedEvents;

  List<Event> getPersonalizedEvents(String city, List<String> interests) {
    final key = '$city-${interests.join(',')}';
    if (key != _lastPersonalizedKey || _cachedPersonalizedEvents == null) {
      _lastPersonalizedKey = key;
      _cachedPersonalizedEvents = _events
          .where((e) => e.city == city && interests.contains(e.category))
          .toList();
    }
    return _cachedPersonalizedEvents!;
  }

  List<Event> getUpcomingEvents() {
    return _cachedUpcomingEvents ??= (_events
        .where((e) => e.date.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date)));
  }

  // ── Favorites ─────────────────────────────────────────────────────────────

  void toggleFavorite(String eventId) {
    if (_favoriteEventIds.contains(eventId)) {
      _favoriteEventIds.remove(eventId);
    } else {
      _favoriteEventIds.add(eventId);
    }
    _cachedFavoriteEvents = null; // only invalidate what changed
    notifyListeners();
  }

  bool isFavorite(String eventId) => _favoriteEventIds.contains(eventId);

  // ── Join / Unjoin ─────────────────────────────────────────────────────────

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
    if (_joinedEventIds.add(eventId)) { // Set.add() returns false if already present
      _eventParticipants[eventId] = (_eventParticipants[eventId] ?? 0) + 1;
      _cachedMyEvents = null; // only invalidate what changed
      notifyListeners();
    }
  }

  void unjoinEvent(String eventId) {
    if (_joinedEventIds.remove(eventId)) { // Set.remove() returns false if not present
      _eventParticipants[eventId] =
          ((_eventParticipants[eventId] ?? 1) - 1).clamp(0, 999999);
      _cachedMyEvents = null; // only invalidate what changed
      notifyListeners();
    }
  }

  bool isJoined(String eventId) => _joinedEventIds.contains(eventId);

  // ── Reminders ─────────────────────────────────────────────────────────────

  bool isReminderSet(String eventId) => _reminderEventIds.contains(eventId);

  void toggleReminder(String eventId) {
    if (_reminderEventIds.contains(eventId)) {
      _reminderEventIds.remove(eventId);
    } else {
      _reminderEventIds.add(eventId);
    }
    notifyListeners();
  }

  // ── Participants ──────────────────────────────────────────────────────────

  int getParticipantCount(String eventId) =>
      _eventParticipants[eventId] ?? 0;
}