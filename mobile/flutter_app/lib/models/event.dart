// This file has been revised
/* Possible conflicts:
1. copyWith with nullable fields — if we ever need to explicitly set imageUrl, price, speaker, attendees, or ticketUrl back to null using copyWith, we can't — null is treated as "no change". This is the standard Dart limitation.
2. date fallback is DateTime.now() — if a bad date comes from the backend, the event will silently show today's date instead of crashing. This is safer but means bad data won't be obvious. Worth adding a debugPrint warning if we want to catch it during development.
*/

class Event {
  final String id;
  final String title;
  final String description;
  final String category; // 'news', 'events', 'concerts', 'seminar'
  final String university;
  final DateTime date;
  final String location;
  final String? imageUrl;
  final double? price;
  final String? speaker;
  final int? attendees;
  final bool isOpenToExternal;
  final String? ticketUrl;
  final String city;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.university,
    required this.date,
    required this.location,
    this.imageUrl,
    this.price,
    this.speaker,
    this.attendees,
    this.isOpenToExternal = false,
    this.ticketUrl,
    required this.city,
  });

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? university,
    DateTime? date,
    String? location,
    String? imageUrl,
    double? price,
    String? speaker,
    int? attendees,
    bool? isOpenToExternal,
    String? ticketUrl,
    String? city,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      university: university ?? this.university,
      date: date ?? this.date,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      speaker: speaker ?? this.speaker,
      attendees: attendees ?? this.attendees,
      isOpenToExternal: isOpenToExternal ?? this.isOpenToExternal,
      ticketUrl: ticketUrl ?? this.ticketUrl,
      city: city ?? this.city,
    );
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      university: json['university'] as String? ?? '',
      // tryParse won't crash on bad/missing date strings
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      location: json['location'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      // price may come as int from some backends — handle both
      price: (json['price'] as num?)?.toDouble(),
      speaker: json['speaker'] as String?,
      attendees: json['attendees'] as int?,
      isOpenToExternal: json['isOpenToExternal'] as bool? ?? false,
      ticketUrl: json['ticketUrl'] as String?,
      city: json['city'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'university': university,
      'date': date.toIso8601String(),
      'location': location,
      'imageUrl': imageUrl,
      'price': price,
      'speaker': speaker,
      'attendees': attendees,
      'isOpenToExternal': isOpenToExternal,
      'ticketUrl': ticketUrl,
      'city': city,
    };
  }
}