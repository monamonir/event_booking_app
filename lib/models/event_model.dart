class Event {
  final int id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final String imageUrl;
  final String category;
  final double price;
  final int capacity;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.imageUrl,
    required this.category,
    required this.price,
    required this.capacity,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '09:00 AM',
      location: json['location'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? 'General',
      price: (json['price'] ?? 0).toDouble(),
      capacity: json['capacity'] ?? 100,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'date': date,
        'time': time,
        'location': location,
        'imageUrl': imageUrl,
        'category': category,
        'price': price,
        'capacity': capacity,
      };

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'date': date,
        'time': time,
        'location': location,
        'imageUrl': imageUrl,
        'category': category,
        'price': price,
        'capacity': capacity,
      };

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '09:00 AM',
      location: map['location'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? 'General',
      price: (map['price'] ?? 0).toDouble(),
      capacity: map['capacity'] ?? 100,
    );
  }
}
