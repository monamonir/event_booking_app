import 'event_model.dart';

class Booking {
  final String id;
  final Event event;
  final DateTime bookedAt;

  Booking({
    required this.id,
    required this.event,
    required this.bookedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event': event.toMap(),
      'bookedAt': bookedAt.toIso8601String(),
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'].toString(),
      event: Event.fromMap(
        Map<String, dynamic>.from(map['event'] as Map),
      ),
      bookedAt: DateTime.parse(map['bookedAt'].toString()),
    );
  }
}
