import 'package:software_for_nature/data/models/event_post.dart';

class EventInteractionState {
  /// Panels shown horizontally in the drawer
  final List<EventPost> openEvents;

  /// Minimized stack on the side
  final List<EventPost> minimizedEvents;

  /// Optional: currently focused event (not strictly required for UI)
  final EventPost? selectedEvent;

  final Set<EventPost> pinnedEvents;

  const EventInteractionState({
    this.openEvents = const [],
    this.minimizedEvents = const [],
    this.selectedEvent,
    this.pinnedEvents = const {},
  });

  EventInteractionState copyWith({
    List<EventPost>? openEvents,
    List<EventPost>? minimizedEvents,
    EventPost? selectedEvent,
    Set<EventPost>? pinnedEvents,
  }) {
    return EventInteractionState(
      openEvents: openEvents ?? this.openEvents,
      minimizedEvents: minimizedEvents ?? this.minimizedEvents,
      selectedEvent: selectedEvent ?? this.selectedEvent,
      pinnedEvents: pinnedEvents ?? this.pinnedEvents,
    );
  }
}