import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';
import '../models/booking_model.dart';

class BookingService {
  static String _getUserKey(String uid) => 'bookings_$uid';

  static Future<List<Booking>> loadBookings(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getUserKey(uid);
    final raw = prefs.getStringList(key) ?? [];
    return raw
        .map((s) => Booking.fromMap(jsonDecode(s)))
        .toList()
        .reversed
        .toList();
  }

  static Future<void> addBooking(Event event, String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getUserKey(uid);
    final existing = prefs.getStringList(key) ?? [];

    final alreadyExists = existing.any((s) {
      final b = Booking.fromMap(jsonDecode(s));
      return b.event.id == event.id;
    });
    if (alreadyExists) return;

    final booking = Booking(
      id: '${event.id}_${DateTime.now().millisecondsSinceEpoch}',
      event: event,
      bookedAt: DateTime.now(),
    );
    existing.add(jsonEncode(booking.toMap()));
    await prefs.setStringList(key, existing);
  }

  static Future<void> removeBooking(String bookingId, String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getUserKey(uid);
    final existing = prefs.getStringList(key) ?? [];
    final updated = existing.where((s) {
      final b = Booking.fromMap(jsonDecode(s));
      return b.id != bookingId;
    }).toList();
    await prefs.setStringList(key, updated);
  }

  static Future<bool> isBooked(int eventId, String uid) async {
    final bookings = await loadBookings(uid);
    return bookings.any((b) => b.event.id == eventId);
  }

  static Future<void> clearUserBookings(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getUserKey(uid);
    await prefs.remove(key);
  }
}
