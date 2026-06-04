part of 'timeline_bloc.dart';

sealed class TimelineEvent {}

class LoadTimelineEvents extends TimelineEvent {}

class SelectTimelineEvent extends TimelineEvent {
  final EventPost post;

  SelectTimelineEvent(this.post);
}