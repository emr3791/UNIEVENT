import 'package:flutter/material.dart';
import '../models/university.dart';

class UniversityProvider with ChangeNotifier {
  List<University> _universities = [];
  bool _isLoading = false;
  String? _error;

  List<University> get universities => _universities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UniversityProvider() {
    _loadMockUniversities();
  }

  void _loadMockUniversities() {
    _universities = [
      const University(
        id: 'uni_1',
        name: 'İstanbul Üniversitesi',
        city: 'İstanbul',
        imageUrl: 'https://picsum.photos/300/200?random=1',
        description:
            'Türkiye\'nin en eski üniversitelerinden biri, 1453\'ten beri eğitim veriyor',
        rating: 4.5,
        studentCount: 45000,
      ),
      const University(
        id: 'uni_2',
        name: 'Boğaziçi Üniversitesi',
        city: 'İstanbul',
        imageUrl: 'https://picsum.photos/300/200?random=2',
        description: 'Prestijli eğitim kurumu, Boğaz kıyısında konumlanmış',
        rating: 4.8,
        studentCount: 12000,
      ),
      const University(
        id: 'uni_6',
        name: 'İstanbul Teknik Üniversitesi (İTÜ)',
        city: 'İstanbul',
        imageUrl: 'https://picsum.photos/300/200?random=3',
        description:
            'Türkiye\'nin önde gelen mühendislik ve teknoloji üniversitesi',
        rating: 4.9,
        studentCount: 32000,
      ),
      const University(
        id: 'uni_7',
        name: 'Yıldız Teknik Üniversitesi',
        city: 'İstanbul',
        imageUrl: 'https://picsum.photos/300/200?random=4',
        description: 'Teknoloji ve mühendislik alanında uzmanlaşmış üniversite',
        rating: 4.4,
        studentCount: 28000,
      ),
      const University(
        id: 'uni_8',
        name: 'Marmara Üniversitesi',
        city: 'İstanbul',
        imageUrl: 'https://picsum.photos/300/200?random=5',
        description: 'Geniş disiplin alanlarında eğitim veren büyük üniversite',
        rating: 4.3,
        studentCount: 90000,
      ),
      const University(
        id: 'uni_9',
        name: 'Koç Üniversitesi',
        city: 'İstanbul',
        imageUrl: 'https://picsum.photos/300/200?random=6',
        description:
            'Dünya kalitesinde eğitim sunan prestijli vakıf üniversitesi',
        rating: 4.7,
        studentCount: 6000,
      ),
      const University(
        id: 'uni_10',
        name: 'Sabancı Üniversitesi',
        city: 'İstanbul',
        imageUrl: 'https://picsum.photos/300/200?random=7',
        description: 'İnovasyon ve teknolojide lider vakıf üniversitesi',
        rating: 4.8,
        studentCount: 5000,
      ),
      const University(
        id: 'uni_11',
        name: 'Bahçeşehir Üniversitesi',
        city: 'İstanbul',
        imageUrl: 'https://picsum.photos/300/200?random=8',
        description: 'Modern eğitim metodları kullanan dinamik üniversite',
        rating: 4.2,
        studentCount: 22000,
      ),
      const University(
        id: 'uni_12',
        name: 'Kadir Has Üniversitesi',
        city: 'İstanbul',
        imageUrl: 'https://picsum.photos/300/200?random=9',
        description: 'İletişim, mühendislik ve tasarım alanlarında uzmanlaşmış',
        rating: 4.5,
        studentCount: 4000,
      ),
      const University(
        id: 'uni_13',
        name: 'Galata Saray Üniversitesi',
        city: 'İstanbul',
        imageUrl: 'https://picsum.photos/300/200?random=10',
        description: 'Uluslararası eğitimde öncü vakıf üniversitesi',
        rating: 4.6,
        studentCount: 3000,
      ),
      const University(
        id: 'uni_14',
        name: 'Okan Üniversitesi',
        city: 'İstanbul',
        imageUrl: 'https://picsum.photos/300/200?random=11',
        description: 'Özgün ve nitelikli eğitim sunan vakıf üniversitesi',
        rating: 4.3,
        studentCount: 15000,
      ),
      const University(
        id: 'uni_15',
        name: 'Beykent Üniversitesi',
        city: 'İstanbul',
        imageUrl: 'https://picsum.photos/300/200?random=12',
        description:
            'Mühendislik ve sağlık bilimleri alanlarında güçlü üniversite',
        rating: 4.2,
        studentCount: 12000,
      ),
      const University(
        id: 'uni_16',
        name: 'Aydın Üniversitesi',
        city: 'İstanbul',
        imageUrl: 'https://picsum.photos/300/200?random=13',
        description: 'Eğitim ve sağlık alanlarında uzmanlaşmış üniversite',
        rating: 4.1,
        studentCount: 18000,
      ),
      const University(
        id: 'uni_17',
        name: 'İstanbul Medeniyet Üniversitesi',
        city: 'İstanbul',
        imageUrl: 'https://picsum.photos/300/200?random=14',
        description: 'Sosyal bilimler alanında öncü eğitim kurumu',
        rating: 4.4,
        studentCount: 11000,
      ),
      const University(
        id: 'uni_18',
        name: 'Arel Üniversitesi',
        city: 'İstanbul',
        imageUrl: 'https://picsum.photos/300/200?random=15',
        description: 'Tasarım ve sağlık alanlarında uzmanlaşmış üniversite',
        rating: 4.2,
        studentCount: 9000,
      ),
      const University(
        id: 'uni_19',
        name: 'Nişantaşı Üniversitesi',
        city: 'İstanbul',
        imageUrl: 'https://picsum.photos/300/200?random=16',
        description: 'İşletme ve turizm alanlarında güçlü üniversite',
        rating: 4.3,
        studentCount: 8500,
      ),
      const University(
        id: 'uni_3',
        name: 'Ankara Üniversitesi',
        city: 'Ankara',
        imageUrl: 'https://picsum.photos/300/200?random=17',
        description: 'Ankara\'nın öncü üniversitesi',
        rating: 4.3,
        studentCount: 35000,
      ),
      const University(
        id: 'uni_4',
        name: 'İzmir Ekonomi Üniversitesi',
        city: 'İzmir',
        imageUrl: 'https://picsum.photos/300/200?random=18',
        description: 'Ekonomi alanında uzmanlaşmış üniversite',
        rating: 4.6,
        studentCount: 8000,
      ),
      const University(
        id: 'uni_5',
        name: 'Hacettepe Üniversitesi',
        city: 'Ankara',
        imageUrl: 'https://picsum.photos/300/200?random=19',
        description: 'Türkiye\'nin öncü araştırma üniversitesi',
        rating: 4.7,
        studentCount: 32000,
      ),
    ];
  }

  Future<void> addUniversity({
    required String name,
    required String city,
    String? imageUrl,
    String? description,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final newUniversity = University(
        id: 'uni_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        city: city,
        imageUrl: imageUrl,
        description: description,
      );

      _universities.add(newUniversity);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUniversities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // API call would go here
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
