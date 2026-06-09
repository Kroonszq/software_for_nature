part of 'hybrid_bloc.dart';

class HybridState {
  final List<EventPost> events;

  final GeoBounds? bounds;
  final DateTimeRange? timeRange;

  final EventPost? selectedEvent;

  final bool loading;

  const HybridState({
    required this.events,
    this.bounds,
    this.timeRange,
    this.selectedEvent,
    this.loading = false,
  });

  HybridState copyWith({
    List<EventPost>? events,
    GeoBounds? bounds,
    DateTimeRange? timeRange,
    EventPost? selectedEvent,
    bool? loading,
  }) {
    return HybridState(
      events: events ?? this.events,
      bounds: bounds ?? this.bounds,
      timeRange: timeRange ?? this.timeRange,
      selectedEvent: selectedEvent ?? this.selectedEvent,
      loading: loading ?? this.loading,
    );
  }
}