part of 'hybrid_bloc.dart';

class HybridState {
  final List<EventPost> events;

  final GeoBounds? bounds;
  final DateTimeRange? timeRange;

  final EventPost? selectedEvent;

  final bool loading;

  final TimeWindow? timeWindow;

  const HybridState({
    required this.events,
    this.bounds,
    this.timeRange,
    this.selectedEvent,
    this.loading = false,
    this.timeWindow
  });

  HybridState copyWith({
    List<EventPost>? events,
    GeoBounds? bounds,
    DateTimeRange? timeRange,
    EventPost? selectedEvent,
    bool? loading,
    TimeWindow? timeWindow,
  }) {
    return HybridState(
      events: events ?? this.events,
      bounds: bounds ?? this.bounds,
      timeRange: timeRange ?? this.timeRange,
      selectedEvent: selectedEvent ?? this.selectedEvent,
      loading: loading ?? this.loading,
      timeWindow: timeWindow ?? this.timeWindow,
    );
  }
}