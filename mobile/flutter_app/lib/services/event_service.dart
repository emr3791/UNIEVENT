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
        imageUrl: 'https://via.placeholder.com/150?text=AI+Semineri',
      ),
      Event(
        id: '2',
        title: 'Flutter Workshop',
        description: 'Mobil uygulama geliştirme workshopu.',
        date: DateTime.now().add(const Duration(days: 5)),
        location: 'Boğaziçi Üniversitesi',
        category: 'Workshop',
        isOpenToExternal: false,
        university: 'Boğaziçi',
        city: 'İstanbul',
        imageUrl: 'https://via.placeholder.com/150?text=Flutter+Workshop',
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
        imageUrl: 'https://via.placeholder.com/150?text=Teknoloji+Konferansi',
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
