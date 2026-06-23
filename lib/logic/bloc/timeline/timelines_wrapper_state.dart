part of 'timelines_wrapper_bloc.dart';

@immutable
sealed class TimeLinesWrapperState {}

final class TimeLinesWrapperInitial extends TimeLinesWrapperState {}

final class TimeLinesWrapperLoaded extends TimeLinesWrapperState {
  final Map<int, Timeline> timelines;
  final Map<int, ScrollController> timelineScrollers;
  final ScrollController axisScrollController;
  final List<int> timelineOrder;

  /// The active date-filter bounds, when one is set. The time axis spans the
  /// whole filtered window so the user sees the full range they selected, not
  /// just the slice where events happen to fall.
  final DateTime? filterStart;
  final DateTime? filterEnd;

  TimeLinesWrapperLoaded({
    required this.timelines,
    required this.timelineScrollers,
    required this.axisScrollController,
    required this.timelineOrder,
    this.filterStart,
    this.filterEnd,
  });

  TimeLinesWrapperLoaded copyWith({
    Map<int, Timeline>? timelines,
    Map<int, ScrollController>? timelineScrollers,
    ScrollController? axisScrollController,
    List<int>? timelineOrder,
    DateTime? filterStart,
    DateTime? filterEnd,
  }) {
    return TimeLinesWrapperLoaded(
      timelines: timelines ?? this.timelines,
      timelineScrollers: timelineScrollers ?? this.timelineScrollers,
      axisScrollController: axisScrollController ?? this.axisScrollController,
      timelineOrder: timelineOrder ?? this.timelineOrder,
      filterStart: filterStart ?? this.filterStart,
      filterEnd: filterEnd ?? this.filterEnd,
    );
  }

  List<EventPost> get allEvents {
    return timelines.values.expand((t) => t.events).toList();
  }

  DateTime? get _eventEarliest {
    if (allEvents.isEmpty) {
      return null;
    }

    return allEvents
        .map((e) => e.startDuration)
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  DateTime? get _eventLatest {
    if (allEvents.isEmpty) {
      return null;
    }

    return allEvents
        .map((e) => e.endDuration)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  /// The earliest point the time axis should cover. When a date filter is
  /// active the axis follows the selected window exactly, so it starts at the
  /// chosen start regardless of where events fall. Otherwise it falls back to
  /// the earliest event.
  DateTime? get earliest => filterStart ?? _eventEarliest;

  /// The latest point the time axis should cover. Mirrors [earliest]: when a
  /// date filter is active the axis ends at the chosen end, instead of
  /// stretching to a long-running event that overlaps the window.
  DateTime? get latest => filterEnd ?? _eventLatest;
}
