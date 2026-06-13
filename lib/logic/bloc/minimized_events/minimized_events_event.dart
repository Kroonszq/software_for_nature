part of 'minimized_events_bloc.dart';

sealed class MinimizedEventsEvent {}

/// Show an event in the drawer 
class OpenEvent extends MinimizedEventsEvent {
  final EventPost post;

  OpenEvent(this.post);
}

/// Minimize the event
class MinimizeEvent extends MinimizedEventsEvent {
  final EventPost post;

  MinimizeEvent(this.post);
}

/// Close the event
class CloseEvent extends MinimizedEventsEvent {
  final EventPost post;

  CloseEvent(this.post);
}

/// Minimize every currently open event into the stack
class MinimizeAllOpen extends MinimizedEventsEvent {}

/// Remove every minimized event from the stack.
class ClearMinimizedEvents extends MinimizedEventsEvent {}
