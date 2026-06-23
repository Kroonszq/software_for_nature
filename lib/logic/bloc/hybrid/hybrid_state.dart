import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/geobounds.dart';
import 'package:software_for_nature/data/models/time_window.dart';


class HybridState {
  final List<EventPost> events;
  final GeoBounds? bounds;
  final TimeWindow timeWindow;
  final EventPost? selectedEvent;
  final bool loading;

  const HybridState({
    required this.events,
    this.bounds,
    required this.timeWindow,
    this.selectedEvent,
    this.loading = false,
  });

  HybridState copyWith({
    List<EventPost>? events,
    GeoBounds? bounds,
    TimeWindow? timeWindow,
    EventPost? selectedEvent,
    bool? loading,
  }) {
    return HybridState(
      events: events ?? this.events,
      bounds: bounds ?? this.bounds,
      timeWindow: timeWindow ?? this.timeWindow,
      selectedEvent: selectedEvent ?? this.selectedEvent,
      loading: loading ?? this.loading,
    );
  }
}