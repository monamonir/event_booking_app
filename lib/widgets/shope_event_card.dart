// ============================================================
// ShopeEventCard — External UI Component
// ============================================================
// Source:  Shope Flutter Ecommerce Template by robertodevs
// GitHub:  https://github.com/robertodevs/flutter_ecommerce_template
// License: MIT
//
// Original component: ProductCard (lib/components/product_card.dart)
// Adaptation: Repurposed for Event Booking App
//   - Product → Event model
//   - Image.asset → Image.network (event images from URL)
//   - Product name label → Event title + price badge
//   - Color scheme updated to match app theme
//
// Used in: home_screen.dart — "Featured Events" horizontal row
// CBSD Project 2026
// ============================================================

import 'package:flutter/material.dart';
import '../models/event_model.dart';

class ShopeEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const ShopeEventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Adapted from Shope ProductCard — uses same layout structure:
    // Container → Column → [image block, flexible name label]
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 200,
        width: MediaQuery.of(context).size.width / 2 - 29,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          // Adapted: original used Color(0xfffbd085), updated to app palette
          color: const Color(0xFF6C63FF).withOpacity(0.10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ── Image block — mirrors Shope's Align > Container > Image ──────
            Align(
              alignment: Alignment.topCenter,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  event.imageUrl,
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    color: const Color(0xFF6C63FF).withOpacity(0.2),
                    child: const Icon(Icons.event,
                        size: 40, color: Colors.white54),
                  ),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 120,
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6C63FF),
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── Name label — mirrors Shope's Flexible > Align > Container ────
            // Original used a right-aligned pill label with product name.
            // Adapted: shows event title + price badge in same pill style.
            Flexible(
              child: Align(
                alignment: const Alignment(1, 0.5),
                child: Container(
                  margin: const EdgeInsets.only(left: 12.0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: const BoxDecoration(
                    // Adapted: original used Color(0xffe0450a), updated to purple
                    color: Color(0xFF6C63FF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        event.title,
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        // Adapted: same font size as original (12.0)
                        style: const TextStyle(
                          fontSize: 11.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.price == 0
                            ? 'FREE'
                            : '\$${event.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
