# event_booking_app

A new Flutter project.

## Custom Reusable Widget

### EventCard (`lib/widgets/event_card.dart`)

A reusable stateless widget for displaying event information.

**Props:**

- `event` (Event) — the event data to display
- `onTap` (VoidCallback) — called when card is tapped
- `onBook` (VoidCallback?) — called when Book button is tapped (optional when already booked)
- `isBooked` (bool) — whether the event is already booked

**Usage:**

```dart
EventCard(
  event: event,
  onTap: () => openDetails(event),
  onBook: () => bookEvent(event),
)
```

**Features:** event image, category badge, title, date, location, price, book button.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
