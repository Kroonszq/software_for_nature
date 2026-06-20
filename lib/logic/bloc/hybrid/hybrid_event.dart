part of 'hybrid_bloc.dart';

sealed class HybridEvent {}

/// Map moved / zoomed
class HybridBoundsChanged extends HybridEvent {
  final GeoBounds bounds;
  HybridBoundsChanged(this.bounds);
}

/// Timeline range changed (optional future feature)
class HybridTimeRangeChanged extends HybridEvent {
  final DateTimeRange range;
  HybridTimeRangeChanged(this.range);
}

/// The category / date / search filter changed. Keeps the map in sync with the
/// timeline so both react to the same filter criteria.
class HybridFilterChanged extends HybridEvent {
  final Set<String>? groupIds;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? search;

  HybridFilterChanged({
    this.groupIds,
    this.startDate,
    this.endDate,
    this.search,
  });
}

/// User selects an event (from map OR timeline)
class HybridEventSelected extends HybridEvent {
  final EventPost event;
  HybridEventSelected(this.event);
}

/// Reload current query (manual refresh if needed)
class HybridReloadRequested extends HybridEvent {}

class HybridTimeWindowChanged extends HybridEvent {
  final TimeWindow window;

  HybridTimeWindowChanged(this.window);
}
