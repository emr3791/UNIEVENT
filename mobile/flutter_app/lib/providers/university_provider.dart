import 'package:flutter/material.dart';
import '../models/university.dart';

// This file has been optimized
/*
1. universities getter now returns List.unmodifiable — if any screen does provider.universities.add(...) or sorts/modifies the list in place, it will throw at runtime. All mutations must go through provider methods.
2. loadUniversities now resets to mock data — previously it was a no-op (just a delay). If any screen calls loadUniversities() expecting it to preserve any universities added via addUniversity(), those will be lost. This is the correct behavior for when a real API is added later, but worth flagging now.
3. getByCity cache only holds one city at a time — if two screens simultaneously filter by different cities (e.g. a tabs layout), one will always miss the cache. If this becomes an issue, change _cachedByCity to a Map<String, List<University>>.
4. addUniversity uses DateTime.now().millisecondsSinceEpoch as ID — if two universities are added within the same millisecond (unlikely but possible in tests), they'll get the same ID. Fine for mock data, needs a proper ID strategy when connecting to a real backend.
*/

class UniversityProvider with ChangeNotifier {
  // Mock data is const — allocated once at compile time, never rebuilt
  static const List<University> _mockUniversities = [
    University(
      id: 'uni_1',
      name: 'İstanbul Üniversitesi',
      city: 'İstanbul',
      imageUrl: 'https://picsum.photos/300/200?random=1',
      description: 'Türkiye\'nin en eski üniversitelerinden biri, 1453\'ten beri eğitim veriyor',
      rating: 4.5,
      studentCount: 45000,
    ),
    University(
      id: 'uni_2',
      name: 'Boğaziçi Üniversitesi',
      city: 'İstanbul',
      imageUrl: 'https://picsum.photos/300/200?random=2',
      description: 'Prestijli eğitim kurumu, Boğaz kıyısında konumlanmış',
      rating: 4.8,
      studentCount: 12000,
    ),
    University(
      id: 'uni_6',
      name: 'İstanbul Teknik Üniversitesi (İTÜ)',
      city: 'İstanbul',
      imageUrl: 'https://picsum.photos/300/200?random=3',
      description: 'Türkiye\'nin önde gelen mühendislik ve teknoloji üniversitesi',
      rating: 4.9,
      studentCount: 32000,
    ),
    University(
      id: 'uni_7',
      name: 'Yıldız Teknik Üniversitesi',
      city: 'İstanbul',
      imageUrl: 'https://picsum.photos/300/200?random=4',
      description: 'Teknoloji ve mühendislik alanında uzmanlaşmış üniversite',
      rating: 4.4,
      studentCount: 28000,
    ),
    University(
      id: 'uni_8',
      name: 'Marmara Üniversitesi',
      city: 'İstanbul',
      imageUrl: 'https://picsum.photos/300/200?random=5',
      description: 'Geniş disiplin alanlarında eğitim veren büyük üniversite',
      rating: 4.3,
      studentCount: 90000,
    ),
    University(
      id: 'uni_9',
      name: 'Koç Üniversitesi',
      city: 'İstanbul',
      imageUrl: 'https://picsum.photos/300/200?random=6',
      description: 'Dünya kalitesinde eğitim sunan prestijli vakıf üniversitesi',
      rating: 4.7,
      studentCount: 6000,
    ),
    University(
      id: 'uni_10',
      name: 'Sabancı Üniversitesi',
      city: 'İstanbul',
      imageUrl: 'https://picsum.photos/300/200?random=7',
      description: 'İnovasyon ve teknolojide lider vakıf üniversitesi',
      rating: 4.8,
      studentCount: 5000,
    ),
    University(
      id: 'uni_11',
      name: 'Bahçeşehir Üniversitesi',
      city: 'İstanbul',
      imageUrl: 'https://picsum.photos/300/200?random=8',
      description: 'Modern eğitim metodları kullanan dinamik üniversite',
      rating: 4.2,
      studentCount: 22000,
    ),
    University(
      id: 'uni_12',
      name: 'Kadir Has Üniversitesi',
      city: 'İstanbul',
      imageUrl: 'https://picsum.photos/300/200?random=9',
      description: 'İletişim, mühendislik ve tasarım alanlarında uzmanlaşmış',
      rating: 4.5,
      studentCount: 4000,
    ),
    University(
      id: 'uni_13',
      name: 'Galata Saray Üniversitesi',
      city: 'İstanbul',
      imageUrl: 'https://picsum.photos/300/200?random=10',
      description: 'Uluslararası eğitimde öncü vakıf üniversitesi',
      rating: 4.6,
      studentCount: 3000,
    ),
    University(
      id: 'uni_14',
      name: 'Okan Üniversitesi',
      city: 'İstanbul',
      imageUrl: 'https://picsum.photos/300/200?random=11',
      description: 'Özgün ve nitelikli eğitim sunan vakıf üniversitesi',
      rating: 4.3,
      studentCount: 15000,
    ),
    University(
      id: 'uni_15',
      name: 'Beykent Üniversitesi',
      city: 'İstanbul',
      imageUrl: 'https://picsum.photos/300/200?random=12',
      description: 'Mühendislik ve sağlık bilimleri alanlarında güçlü üniversite',
      rating: 4.2,
      studentCount: 12000,
    ),
    University(
      id: 'uni_16',
      name: 'Aydın Üniversitesi',
      city: 'İstanbul',
      imageUrl: 'https://picsum.photos/300/200?random=13',
      description: 'Eğitim ve sağlık alanlarında uzmanlaşmış üniversite',
      rating: 4.1,
      studentCount: 18000,
    ),
    University(
      id: 'uni_17',
      name: 'İstanbul Medeniyet Üniversitesi',
      city: 'İstanbul',
      imageUrl: 'https://picsum.photos/300/200?random=14',
      description: 'Sosyal bilimler alanında öncü eğitim kurumu',
      rating: 4.4,
      studentCount: 11000,
    ),
    University(
      id: 'uni_18',
      name: 'Arel Üniversitesi',
      city: 'İstanbul',
      imageUrl: 'https://picsum.photos/300/200?random=15',
      description: 'Tasarım ve sağlık alanlarında uzmanlaşmış üniversite',
      rating: 4.2,
      studentCount: 9000,
    ),
    University(
      id: 'uni_19',
      name: 'Nişantaşı Üniversitesi',
      city: 'İstanbul',
      imageUrl: 'https://picsum.photos/300/200?random=16',
      description: 'İşletme ve turizm alanlarında güçlü üniversite',
      rating: 4.3,
      studentCount: 8500,
    ),
    University(
      id: 'uni_3',
      name: 'Ankara Üniversitesi',
      city: 'Ankara',
      imageUrl: 'https://picsum.photos/300/200?random=17',
      description: 'Ankara\'nın öncü üniversitesi',
      rating: 4.3,
      studentCount: 35000,
    ),
    University(
      id: 'uni_4',
      name: 'İzmir Ekonomi Üniversitesi',
      city: 'İzmir',
      imageUrl: 'https://picsum.photos/300/200?random=18',
      description: 'Ekonomi alanında uzmanlaşmış üniversite',
      rating: 4.6,
      studentCount: 8000,
    ),
    University(
      id: 'uni_5',
      name: 'Hacettepe Üniversitesi',
      city: 'Ankara',
      imageUrl: 'https://picsum.photos/300/200?random=19',
      description: 'Türkiye\'nin öncü araştırma üniversitesi',
      rating: 4.7,
      studentCount: 32000,
    ),
  ];

  List<University> _universities = List.of(_mockUniversities);
  bool _isLoading = false;
  String? _error;

  // Cached city filter — avoids refiltering on every build()
  String? _lastCityFilter;
  List<University>? _cachedByCity;

  UniversityProvider() {
    // No async work needed — mock data is already loaded above
  }

  List<University> get universities => List.unmodifiable(_universities);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Internal helpers ──────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _invalidateCache() {
    _lastCityFilter = null;
    _cachedByCity = null;
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  List<University> getByCity(String city) {
    if (_lastCityFilter == city && _cachedByCity != null) {
      return _cachedByCity!;
    }
    _lastCityFilter = city;
    _cachedByCity = _universities
        .where((u) => u.city.toLowerCase() == city.toLowerCase())
        .toList();
    return _cachedByCity!;
  }

  University? getById(String id) {
    try {
      return _universities.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  Future<void> addUniversity({
    required String name,
    required String city,
    String? imageUrl,
    String? description,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _universities.add(University(
        id: 'uni_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        city: city,
        imageUrl: imageUrl,
        description: description,
      ));
      _invalidateCache();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUniversities() async {
    _setLoading(true);
    _error = null;
    try {
      // API call would go here — for now resets to mock data
      await Future.delayed(const Duration(milliseconds: 500));
      _universities = List.of(_mockUniversities);
      _invalidateCache();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
}