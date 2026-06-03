part of 'timelines_wrapper_bloc.dart';

@immutable
sealed class TimeLinesWrapperEvent {}

final class LoadTimelineEvents extends TimeLinesWrapperEvent{
}

/// Sets the timeline active in the wrapper.
final class SetTimelineActive extends TimeLinesWrapperEvent{
  final int timelineHash;

  SetTimelineActive(this.timelineHash);
}

/// Sets the timeline inactive in the wrapper.
final class SetTimelineInActive extends TimeLinesWrapperEvent{
  final int timelineHash;

  SetTimelineInActive(this.timelineHash);
}

final class TimelineScroll extends TimeLinesWrapperEvent{
  final ScrollController scrollController;

  TimelineScroll(this.scrollController);
}


final class ReorderTimeline extends TimeLinesWrapperEvent {
  final int oldIndex;
  final int newIndex;
  ReorderTimeline(this.oldIndex, this.newIndex);
}
