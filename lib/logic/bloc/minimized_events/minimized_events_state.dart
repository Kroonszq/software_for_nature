part of 'minimized_events_bloc.dart';

class MinimizedEventsState {
  /// Events currently shown in the drawer
  final List<EventPost> openEvents;

  /// Events the user has minimized
  final List<EventPost> minimized;

  const MinimizedEventsState({
    this.openEvents = const [],
    this.minimized = const [],
  });

  MinimizedEventsState copyWith({
    List<EventPost>? openEvents,
    List<EventPost>? minimized,
  }) {
    return MinimizedEventsState(
      openEvents: openEvents ?? this.openEvents,
      minimized: minimized ?? this.minimized,
    );
  }
}
