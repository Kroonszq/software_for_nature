part of 'timeline_bloc.dart';

sealed class TimelineEvent {}

class LoadTimelineEvents extends TimelineEvent {}

class SelectTimelineEvent extends TimelineEvent {
  final EventPost post;

  SelectTimelineEvent(this.post);
}

/// Select [post] AND request the timeline scroll it into view (used when the
/// event is hovered from somewhere off-screen, e.g. a map marker).
class FocusTimelineEvent extends TimelineEvent {
  final EventPost post;

  FocusTimelineEvent(this.post);
}

class UnSelectTimelineEvent extends TimelineEvent {
  UnSelectTimelineEvent();
}
