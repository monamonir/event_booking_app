import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added for UID
import '../models/event_model.dart';
import '../services/booking_service.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _isBooked = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkBooked();
  }

  Future<void> _checkBooked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final booked = await BookingService.isBooked(widget.event.id, user.uid);
      if (mounted) setState(() => _isBooked = booked);
    }
  }

  Future<void> _book() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _loading = true);
    await BookingService.bookEvent(widget.event, user.uid);
    if (mounted) {
      setState(() {
        _isBooked = true;
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🎉 Event booked successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  String _formatDate(String date) {
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        const months = [
          '',
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];
        final month = int.tryParse(parts[1]) ?? 1;
        return '${months[month]} ${parts[2]}, ${parts[0]}';
      }
    } catch (_) {}
    return date;
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: const Color(0xFF6C63FF),
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.black87, size: 18),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    event.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF6C63FF).withOpacity(0.3),
                      child: const Icon(Icons.event,
                          size: 80, color: Colors.white54),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          event.category,
                          style: const TextStyle(
                            color: Color(0xFF6C63FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.calendar_today_rounded,
                              label: 'Date',
                              value: _formatDate(event.date),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.access_time_rounded,
                              label: 'Time',
                              value: event.time,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.location_on_rounded,
                        label: 'Location',
                        value: event.location,
                        iconColor: Colors.redAccent,
                        fullWidth: true,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'About Event',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.people_outline,
                              color: Color(0xFF6C63FF), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '${event.capacity} spots available',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Price',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        event.price == 0
                            ? 'FREE'
                            : '\$${event.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: event.price == 0
                              ? Colors.green
                              : const Color(0xFF6C63FF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: _loading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF6C63FF)))
                          : ElevatedButton(
                              onPressed: _isBooked ? null : _book,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isBooked
                                    ? Colors.green
                                    : const Color(0xFF6C63FF),
                                disabledBackgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              child: Text(
                                _isBooked
                                    ? '✓ Already Booked'
                                    : 'Book This Event',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final bool fullWidth;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor = const Color(0xFF6C63FF),
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E)),
                    maxLines: fullWidth ? 2 : 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
