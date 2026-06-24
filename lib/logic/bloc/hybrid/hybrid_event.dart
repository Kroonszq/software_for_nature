part of 'hybrid_bloc.dart';

sealed class HybridEvent {}

class HybridBoundsChanged extends HybridEvent {
  final GeoBounds bounds;
  HybridBoundsChanged(this.bounds);
}

class HybridTimeRangeChanged extends HybridEvent {
  final DateTimeRange range;
  HybridTimeRangeChanged(this.range);
}

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

class HybridVisibleCategoriesChanged extends HybridEvent {
  final Set<String> categoryIds;
  HybridVisibleCategoriesChanged(this.categoryIds);
}

class HybridEventSelected extends HybridEvent {
  final EventPost event;
  HybridEventSelected(this.event);
}

class HybridReloadRequested extends HybridEvent {}

class HybridTimeWindowChanged extends HybridEvent {
  final TimeWindow window;

  HybridTimeWindowChanged(this.window);
}
