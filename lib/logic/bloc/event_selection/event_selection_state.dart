import 'package:software_for_nature/data/models/event_post.dart';

class EventSelectionState {
  final List<EventPost> selected;
  final List<EventPost> minimized;
  final EventPost? hovered;

  const EventSelectionState({
    this.selected = const [],
    this.minimized = const [],
    this.hovered,
  });

  EventSelectionState copyWith({
    List<EventPost>? selected,
    List<EventPost>? minimized,
    EventPost? hovered,
  }) {
    return EventSelectionState(
      selected: selected ?? this.selected,
      minimized: minimized ?? this.minimized,
      hovered: hovered,
    );
  }
}