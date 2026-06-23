part of 'hybrid_bloc.dart';

sealed class HybridEvent {}

/// Map moved / zoomed
class HybridBoundsChanged extends HybridEvent {
  final GeoBounds bounds;
  HybridBoundsChanged(this.bounds);
}

/// Timeline range changed 
class HybridTimeRangeChanged extends HybridEvent {
  final DateTimeRange range;
  HybridTimeRangeChanged(this.range);
}

/// The category / date / search filter changed
class HybridFilterChanged extends HybridEvent {
  final Set<String>? categoryIds;
  final Set<String>? tagLabels;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? search;

  HybridFilterChanged({
    this.categoryIds,
    this.tagLabels,
    this.startDate,
    this.endDate,
    this.search,
  });
}

/// The set of categories currently shown by the timeline changed
class HybridVisibleCategoriesChanged extends HybridEvent {
  final Set<String> categoryIds;
  HybridVisibleCategoriesChanged(this.categoryIds);
}

/// User selects an event (from map OR timeline)
class HybridEventSelected extends HybridEvent {
  final EventPost event;
  HybridEventSelected(this.event);
}

/// Reload current query
class HybridReloadRequested extends HybridEvent {}

class HybridTimeWindowChanged extends HybridEvent {
  final TimeWindow window;

  HybridTimeWindowChanged(this.window);
}
