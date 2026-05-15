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

### Separate Repository

The reusable EventCard widget is also published as a standalone package repository:

https://github.com/monamonir/event_card_widget
