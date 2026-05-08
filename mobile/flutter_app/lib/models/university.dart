// This file has been revised
/* Potential conflicts:
1. eventIds filter — empty strings are now filtered out. If anything in the app checks eventIds?.length and expects it to match the raw JSON list length exactly, the count may differ when bad data is present.
2. Same copyWith nullable limitation as Event — we can't set nullable fields back to null via copyWith.
*/

class University {
  final String id;
  final String name;
  final String city;
  final String? imageUrl;
  final String? description;
  final double? rating;
  final int? studentCount;
  final List<String>? eventIds;

  const University({
    required this.id,
    required this.name,
    required this.city,
    this.imageUrl,
    this.description,
    this.rating,
    this.studentCount,
    this.eventIds,
  });

  University copyWith({
    String? id,
    String? name,
    String? city,
    String? imageUrl,
    String? description,
    double? rating,
    int? studentCount,
    List<String>? eventIds,
  }) {
    return University(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      studentCount: studentCount ?? this.studentCount,
      eventIds: eventIds ?? this.eventIds,
    );
  }

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      // rating may come as int from some backends — handle both
      rating: (json['rating'] as num?)?.toDouble(),
      studentCount: json['studentCount'] as int?,
      // Safely map each item to String in case backend sends non-strings
      eventIds: (json['eventIds'] as List?)
          ?.map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'imageUrl': imageUrl,
      'description': description,
      'rating': rating,
      'studentCount': studentCount,
      'eventIds': eventIds,
    };
  }
}