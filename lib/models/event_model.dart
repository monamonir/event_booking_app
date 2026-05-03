class Event {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String date;
  final String location;
  final double price;
  final String category;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.date,
    required this.location,
    required this.price,
    required this.category,
  });

  // We'll use a mock API (JSONPlaceholder-style), so we map fields creatively
  factory Event.fromJson(Map<String, dynamic> json, int index) {
    final categories = ['Music', 'Tech', 'Sports', 'Art', 'Food'];
    final locations = ['Cairo', 'Alexandria', 'Giza', 'Luxor', 'Aswan'];
    return Event(
      id: json['id'],
      title: json['title'] ?? 'Event ${json['id']}',
      description: json['body'] ?? 'No description available.',
      imageUrl: 'https://picsum.photos/seed/${json['id']}/400/200',
      date: '2026-0${(index % 9) + 1}-${(index % 28) + 1}',
      location: locations[index % locations.length],
      price: ((index % 10) * 50 + 50).toDouble(),
      category: categories[index % categories.length],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'date': date,
      'location': location,
      'price': price,
      'category': category,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      date: map['date'],
      location: map['location'],
      price: map['price'],
      category: map['category'],
    );
  }
}