part of 'map_bloc.dart';

sealed class MapEvent {}

class LoadMapEvents extends MapEvent {}

class SelectMapEvent extends MapEvent {
  final EventPost post;

  SelectMapEvent(this.post);
}

class UpdateMapBounds extends MapEvent {
  final GeoBounds bounds;

  UpdateMapBounds(this.bounds);
}

class UpdateTimeWindow extends MapEvent {
  final TimeWindow window;

  UpdateTimeWindow(this.window);
}

/// Applies the shared filter (categories, tags, date range, search) to themap's events
class MapFilterChanged extends MapEvent {
  final Set<String>? categoryIds;
  final Set<String>? tagLabels;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? search;

  MapFilterChanged({
    this.categoryIds,
    this.tagLabels,
    this.startDate,
    this.endDate,
    this.search,
  });
}