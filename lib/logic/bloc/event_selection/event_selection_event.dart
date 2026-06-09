import 'package:software_for_nature/data/models/event_post.dart';

sealed class EventSelectionEvent {}

class HoverEvent extends EventSelectionEvent {
  final EventPost? event;
  HoverEvent(this.event);
}

class SelectEvent extends EventSelectionEvent {
  final EventPost event;
  SelectEvent(this.event);
}

class CloseEvent extends EventSelectionEvent {
  final EventPost event;
  CloseEvent(this.event);
}

class MinimizeEvent extends EventSelectionEvent {
  final EventPost event;
  MinimizeEvent(this.event);
}

class RestoreEvent extends EventSelectionEvent {
  final EventPost event;
  RestoreEvent(this.event);
}