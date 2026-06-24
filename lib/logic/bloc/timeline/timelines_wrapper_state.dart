part of 'timelines_wrapper_bloc.dart';

@immutable
sealed class TimeLinesWrapperState {}

final class TimeLinesWrapperInitial extends TimeLinesWrapperState {}

final class TimeLinesWrapperLoaded extends TimeLinesWrapperState {
  final Map<int, Timeline> timelines;
  final Map<int, ScrollController> timelineScrollers;
  final ScrollController axisScrollController;
  final List<int> timelineOrder;


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


  DateTime? get earliest => filterStart ?? _eventEarliest;
  DateTime? get latest => filterEnd ?? _eventLatest;
}
