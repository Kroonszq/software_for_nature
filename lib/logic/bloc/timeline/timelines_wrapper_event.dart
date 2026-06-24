part of 'timelines_wrapper_bloc.dart';

@immutable
sealed class TimeLinesWrapperEvent {}

final class LoadTimelineEvents extends TimeLinesWrapperEvent {}


final class FilterChanged extends TimeLinesWrapperEvent {
  final List<Category> activeCategories;
  final Set<String> tagLabels;
  final DateTime? startDate;
  final DateTime? endDate;
  final String searchQuery;

  FilterChanged({
    this.activeCategories = const [],
    this.tagLabels = const {},
    this.startDate,
    this.endDate,
    this.searchQuery = '',
  });
}

final class SetTimelineActive extends TimeLinesWrapperEvent {
  final int timelineHash;

  SetTimelineActive(this.timelineHash);
}

final class SetTimelineInActive extends TimeLinesWrapperEvent {
  final int timelineHash;

  SetTimelineInActive(this.timelineHash);
}

final class SetTimelineFullscreen extends TimeLinesWrapperEvent {
  final int timelineHash;

  SetTimelineFullscreen(this.timelineHash);
}

final class SetTimelineNormalScreen extends TimeLinesWrapperEvent {
  final int timelineHash;

  SetTimelineNormalScreen(this.timelineHash);
}

final class ReorderTimeline extends TimeLinesWrapperEvent {
  final int oldIndex;
  final int newIndex;
  ReorderTimeline(this.oldIndex, this.newIndex);
}
