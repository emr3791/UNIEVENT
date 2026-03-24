class EventModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime date;
  final double latitude;
  final double longitude;
  final String locationName;
  final bool isPublic;
  final String targetUniversityCode; // 'ALL', 'TECH', 'ART'
  final double price;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.isPublic,
    required this.targetUniversityCode,
    required this.price,
  });

  bool canAccess(String userUniversityCode) {
    if (isPublic) return true;
    if (targetUniversityCode == 'ALL') return true;
    return targetUniversityCode == userUniversityCode;
  }
}

// Mock Data
final List<EventModel> mockEvents = [
  EventModel(
    id: '1',
    title: 'Neon Kampüs Partisi',
    description: 'Yılın en büyük kampüs içi DJ performansı.',
    imageUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?q=80&w=1000&auto=format&fit=crop',
    date: DateTime.now().add(const Duration(days: 2)),
    latitude: 41.0082,
    longitude: 28.9784,
    locationName: 'Ana Meydan',
    isPublic: false,
    targetUniversityCode: 'TECH',
    price: 50.0,
  ),
  EventModel(
    id: '2',
    title: 'Açık Hava Sineması',
    description: 'Interstellar gösterimi, herkese açık!',
    imageUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?q=80&w=1000&auto=format&fit=crop',
    date: DateTime.now().add(const Duration(days: 5)),
    latitude: 41.0122,
    longitude: 28.9814,
    locationName: 'Güney Çimler',
    isPublic: true,
    targetUniversityCode: 'ALL',
    price: 0.0,
  ),
  EventModel(
    id: '3',
    title: 'Teknoloji Zirvesi 2024',
    description: 'Sektörün devleri kampüste buluşuyor.',
    imageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?q=80&w=1000&auto=format&fit=crop',
    date: DateTime.now().add(const Duration(days: 10)),
    latitude: 41.0152,
    longitude: 28.9754,
    locationName: 'Kongre Merkezi',
    isPublic: false,
    targetUniversityCode: 'TECH',
    price: 150.0,
  ),
  EventModel(
    id: '4',
    title: 'Güzel Sanatlar Sergisi',
    description: 'Dönem sonu projeleri görücüye çıkıyor.',
    imageUrl: 'https://images.unsplash.com/photo-1518998053901-5348d3961a04?q=80&w=1000&auto=format&fit=crop',
    date: DateTime.now().add(const Duration(days: 1)),
    latitude: 41.0202,
    longitude: 28.9804,
    locationName: 'Güzel Sanatlar Fakültesi',
    isPublic: false,
    targetUniversityCode: 'ART',
    price: 20.0,
  ),
];
