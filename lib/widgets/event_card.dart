/// EventCard — Custom Reusable Widget
/// CBSD Project 2026
///
/// Usage:
///   EventCard(
///     event: myEvent,
///     isBooked: false,
///     onTap: () => navigateToDetails(),
///     onBook: () => bookEvent(),
///   )

import 'package:flutter/material.dart';
import '../models/event_model.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final VoidCallback? onBook;
  final bool isBooked;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.onBook,
    this.isBooked = false,
  });

  String _formatDate(String date) {
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        const months = [
          '',
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        final month = int.tryParse(parts[1]) ?? 1;
        return '${months[month]} ${parts[2]}, ${parts[0]}';
      }
    } catch (_) {}
    return date;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image with category badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Image.network(
                    event.imageUrl,
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 170,
                      color: const Color(0xFF6C63FF).withOpacity(0.15),
                      child: const Icon(Icons.event,
                          size: 56, color: Colors.white54),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 170,
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF6C63FF), strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
                // Category badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.category,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            // Event info
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Date
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 13, color: Color(0xFF6C63FF)),
                      const SizedBox(width: 5),
                      Text(
                        _formatDate(event.date),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 13, color: Colors.redAccent),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          event.location,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Price + Book button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Price',
                              style:
                                  TextStyle(fontSize: 11, color: Colors.grey)),
                          Text(
                            event.price == 0
                                ? 'FREE'
                                : '\$${event.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: event.price == 0
                                  ? Colors.green
                                  : const Color(0xFF6C63FF),
                            ),
                          ),
                        ],
                      ),
                      if (onBook != null)
                        ElevatedButton(
                          onPressed: isBooked ? null : onBook,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isBooked
                                ? Colors.green
                                : const Color(0xFF6C63FF),
                            disabledBackgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          child: Text(
                            isBooked ? '✓ Booked' : 'Book Now',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
