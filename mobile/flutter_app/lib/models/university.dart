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

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      rating: json['rating'] as double?,
      studentCount: json['studentCount'] as int?,
      eventIds: List<String>.from(json['eventIds'] as List? ?? []),
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
