import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class EventService {
  // Use a host like '192.168.0.100' or pass the actual device IP when calling fetchEvents
  // Endpoint: http://<host>:3000/api/events

  // Mock data for now (fallback)
  static List<Event> getMockEvents() {
    return [
      Event(
        id: '1',
        title: 'Yapay Zeka Semineri',
        description: 'AI teknolojileri hakkında kapsamlı seminer.',
        date: DateTime.now().add(const Duration(days: 2)),
        location: 'İstanbul Teknik Üniversitesi',
        category: 'Seminer',
        isOpenToExternal: true,
        ticketUrl: 'https://example.com/ticket1',
        university: 'İTÜ',
        city: 'İstanbul',
        imageUrl:
            'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=1200&q=80',
      ),
      Event(
        id: '2',
        title: 'Flutter Workshop',
        description: 'Mobil uygulama geliştirme workshopu.',
        date: DateTime.now().add(const Duration(days: 5)),
        location: 'Boğaziçi Üniversitesi',
        category: 'Seminer',
        isOpenToExternal: false,
        university: 'Boğaziçi',
        city: 'İstanbul',
        imageUrl:
            'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=1200&q=80',
      ),
      Event(
        id: '3',
        title: 'Konferans: Geleceğin Teknolojileri',
        description: 'Teknoloji trendleri konferansı.',
        date: DateTime.now().add(const Duration(days: 10)),
        location: 'ODTÜ',
        category: 'Konferans',
        isOpenToExternal: true,
        ticketUrl: 'https://example.com/ticket3',
        university: 'ODTÜ',
        city: 'Ankara',
        imageUrl:
            'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=1200&q=80',
      ),
      Event(
        id: '4',
        title: 'Açık Hava Konseri',
        description: 'Yaz akşamında canlı müzik ve DJ performansı.',
        date: DateTime.now().add(const Duration(days: 7)),
        location: 'İstanbul Üniversitesi',
        category: 'Konser',
        isOpenToExternal: true,
        university: 'İstanbul Üniversitesi',
        city: 'İstanbul',
        imageUrl:
            'https://images.unsplash.com/photo-1485846234645-a62644f84728?auto=format&fit=crop&w=1200&q=80',
      ),
      Event(
        id: '5',
        title: 'UniEvent Duyuru: Yeni Kampüs Rehberi',
        description:
            'Üniversitenizdeki yeni rehber uygulaması hakkında detaylar.',
        date: DateTime.now().add(const Duration(days: 1)),
        location: 'Online',
        category: 'news',
        isOpenToExternal: true,
        university: 'UniEvent',
        city: 'Online',
        imageUrl:
            'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=1200&q=80',
      ),
    ];
  }

  Future<List<Event>> fetchEvents({String host = '192.168.0.100'}) async {
    final uri = Uri.parse('http://$host:3000/api/events');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Event.fromJson(json)).toList();
      } else {
        // If backend returns error, fall back to mock data
        return getMockEvents();
      }
    } catch (e) {
      // On exception (timeout, network), return mock data as fallback
      return getMockEvents();
    }
  }
}
