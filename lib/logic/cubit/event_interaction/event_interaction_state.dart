import 'package:software_for_nature/data/models/event_post.dart';

class EventInteractionState {
  final List<EventPost> openEvents;

  final List<EventPost> minimizedEvents;

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