import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';
import '../models/booking_model.dart';

class BookingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'bookings';

  static String _getUserKey(String uid) => 'bookings_$uid';

  static Future<List<Booking>> _loadLocalBookings(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getUserKey(uid);
    final raw = prefs.getStringList(key) ?? [];
    return raw.map((s) => Booking.fromMap(jsonDecode(s))).toList();
  }

  static Future<List<Booking>> _loadFirestoreBookings(String uid) async {
    try {
      final snap =
          await _firestore.collection(_collection).doc(uid).get();
      if (!snap.exists || snap.data() == null) return [];
      final raw = snap.data()!['bookings'];
      if (raw is! List) return [];
      final out = <Booking>[];
      for (final item in raw) {
        if (item is Map) {
          try {
            out.add(
              Booking.fromMap(Map<String, dynamic>.from(item)),
            );
          } catch (_) {}
        }
      }
      return out;
    } catch (_) {
      return [];
    }
  }

  static Future<void> _saveFirestoreBookings(
    String uid,
    List<Booking> bookings,
  ) async {
    await _firestore.collection(_collection).doc(uid).set(
      {
        'bookings': bookings.map((b) => b.toMap()).toList(),
      },
      SetOptions(merge: true),
    );
  }

  /// One row per [event.id]; prefers the booking with the latest [bookedAt].
  static List<Booking> _mergeLocalAndRemote(
    List<Booking> local,
    List<Booking> remote,
  ) {
    final byEventId = <int, Booking>{};
    void consider(Booking b) {
      final prev = byEventId[b.event.id];
      if (prev == null || b.bookedAt.isAfter(prev.bookedAt)) {
        byEventId[b.event.id] = b;
      }
    }

    for (final b in remote) {
      consider(b);
    }
    for (final b in local) {
      consider(b);
    }

    final merged = byEventId.values.toList()
      ..sort((a, b) => b.bookedAt.compareTo(a.bookedAt));
    return merged;
  }

  /// Merges SharedPreferences bookings with Firestore `bookings/{uid}` data.
  static Future<List<Booking>> getBookings(String uid) async {
    final local = await _loadLocalBookings(uid);
    final remote = await _loadFirestoreBookings(uid);
    return _mergeLocalAndRemote(local, remote);
  }

  /// Saves locally and syncs the merged list to Firestore (`bookings` doc id = [uid]).
  static Future<void> bookEvent(Event event, String uid) async {
    final mergedBefore = await getBookings(uid);
    if (mergedBefore.any((b) => b.event.id == event.id)) return;

    final booking = Booking(
      id: '${event.id}_${DateTime.now().millisecondsSinceEpoch}',
      event: event,
      bookedAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    final key = _getUserKey(uid);
    final existing = prefs.getStringList(key) ?? [];
    existing.add(jsonEncode(booking.toMap()));
    await prefs.setStringList(key, existing);

    final local = await _loadLocalBookings(uid);
    final remote = await _loadFirestoreBookings(uid);
    await _saveFirestoreBookings(uid, _mergeLocalAndRemote(local, remote));
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

    final remote = await _loadFirestoreBookings(uid);
    remote.removeWhere((b) => b.id == bookingId);
    await _saveFirestoreBookings(uid, remote);
  }

  static Future<bool> isBooked(int eventId, String uid) async {
    final bookings = await getBookings(uid);
    return bookings.any((b) => b.event.id == eventId);
  }

  static Future<void> clearUserBookings(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getUserKey(uid);
    await prefs.remove(key);
    try {
      await _firestore.collection(_collection).doc(uid).delete();
    } catch (_) {}
  }
}
