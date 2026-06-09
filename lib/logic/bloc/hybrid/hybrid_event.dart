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

/// User selects an event (from map OR timeline)
class HybridEventSelected extends HybridEvent {
  final EventPost event;
  HybridEventSelected(this.event);
}

/// Reload current query (manual refresh if needed)
class HybridReloadRequested extends HybridEvent {}