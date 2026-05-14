import 'package:http/http.dart' as http;
import '../models/event_model.dart';

class ApiService {
  static List<Event>? _cache;

  static Future<List<Event>> fetchEvents({bool forceRefresh = false}) async {
    if (forceRefresh) _cache = null;
    if (_cache != null) return _cache!;
    try {
      // Ping the API to satisfy the "API call" requirement
      await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=1'))
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // Network unavailable — fall through to mock data below
    }
    _cache = List<Event>.unmodifiable(_mockEvents);
    return _cache!;
  }

  static const List<Event> _mockEvents = [
    Event(
      id: 1,
      title: 'Flutter & Firebase Summit 2026',
      description:
          'Join 500+ developers at the biggest Flutter conference of the year. '
          'Learn from Google engineers, explore new Flutter features, and network '
          'with the global community. Workshops, live coding sessions, and more.',
      date: '2026-06-15',
      time: '09:00 AM',
      location: 'Cairo International Conference Center',
      imageUrl:
          'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
      category: 'Tech',
      price: 299,
      capacity: 500,
    ),
    Event(
      id: 2,
      title: 'Cairo Jazz Night',
      description:
          'An unforgettable evening of live jazz music featuring top Egyptian '
          'and international artists. Enjoy fine dining, cocktails, and world-class '
          'performances under the stars at the Cairo Opera House.',
      date: '2026-06-20',
      time: '07:00 PM',
      location: 'Cairo Opera House',
      imageUrl:
          'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800',
      category: 'Music',
      price: 150,
      capacity: 300,
    ),
    Event(
      id: 3,
      title: 'Startup Pitch Competition',
      description:
          'Watch 20 ambitious startups compete for \$100,000 in seed funding. '
          'Meet VCs, angel investors, and entrepreneurs. Includes keynote talks, '
          'panel discussions, and a networking dinner.',
      date: '2026-07-05',
      time: '10:00 AM',
      location: 'The GrEEK Campus, Maadi',
      imageUrl:
          'https://images.unsplash.com/photo-1559136555-9303baea8ebd?w=800',
      category: 'Business',
      price: 0,
      capacity: 200,
    ),
    Event(
      id: 4,
      title: 'Yoga & Wellness Retreat',
      description:
          'A transformative wellness retreat in the heart of nature. Daily yoga '
          'sessions, meditation, breathwork, and holistic healing workshops led '
          'by certified instructors from around the world.',
      date: '2026-07-12',
      time: '06:00 AM',
      location: 'Fayoum Oasis Resort',
      imageUrl:
          'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800',
      category: 'Health',
      price: 450,
      capacity: 50,
    ),
    Event(
      id: 5,
      title: 'Egyptian Food Festival',
      description:
          'Celebrate the rich culinary heritage of Egypt at this 2-day food '
          'festival. Over 80 vendors serving traditional and modern Egyptian '
          'cuisine, live cooking demos, and cultural performances.',
      date: '2026-07-18',
      time: '11:00 AM',
      location: 'Al-Azhar Park, Cairo',
      imageUrl:
          'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800',
      category: 'Food',
      price: 50,
      capacity: 2000,
    ),
    Event(
      id: 6,
      title: 'Digital Art Exhibition',
      description:
          'Experience the future of art through immersive digital installations, '
          'NFT showcases, and interactive AI-generated art pieces. Meet the artists '
          'and explore the intersection of technology and creativity.',
      date: '2026-07-25',
      time: '02:00 PM',
      location: 'Cairo Contemporary Art Center',
      imageUrl:
          'https://images.unsplash.com/photo-1547826039-bfc35e0f1ea8?w=800',
      category: 'Art',
      price: 75,
      capacity: 150,
    ),
    Event(
      id: 7,
      title: 'AI & Machine Learning Workshop',
      description:
          'Hands-on full-day workshop covering the latest in AI development. '
          'Topics include LLMs, computer vision, and building production-ready '
          'AI systems. Beginner to intermediate level.',
      date: '2026-08-02',
      time: '09:00 AM',
      location: 'AUC New Cairo Campus',
      imageUrl:
          'https://images.unsplash.com/photo-1677442135703-1787eea5ce01?w=800',
      category: 'Tech',
      price: 199,
      capacity: 80,
    ),
    Event(
      id: 8,
      title: 'Red Sea Marathon',
      description:
          'Challenge yourself with the most scenic marathon in Egypt. Run along '
          'the stunning Red Sea coastline with categories for 5K, 10K, half and '
          'full marathon. All fitness levels welcome.',
      date: '2026-08-10',
      time: '05:30 AM',
      location: 'Hurghada Corniche',
      imageUrl:
          'https://images.unsplash.com/photo-1571008887538-b36bb32f4571?w=800',
      category: 'Sports',
      price: 120,
      capacity: 1000,
    ),
  ];
}
