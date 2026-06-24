import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/logic/cubit/event_interaction/event_interaction_state.dart';

class EventInteractionCubit extends Cubit<EventInteractionState> {
  EventInteractionCubit() : super(const EventInteractionState());

  void select(EventPost event) {
   
    final updated = List<EventPost>.from(state.openEvents)
      ..removeWhere((e) => e.id == event.id)
      ..add(event);

    emit(state.copyWith(
      openEvents: updated,
      selectedEvent: event,
    ));
  }

  void replace(EventPost event) {
    List<EventPost> swap(List<EventPost> list) =>
        [for (final e in list) e.id == event.id ? event : e];

    emit(state.copyWith(
      openEvents: swap(state.openEvents),
      minimizedEvents: swap(state.minimizedEvents),
      selectedEvent:
          state.selectedEvent?.id == event.id ? event : state.selectedEvent,
    ));
  }

  void closeSelected() {
    emit(state.copyWith(selectedEvent: null));
  }

  void minimize(EventPost event) {
    final open = List<EventPost>.from(state.openEvents)
      ..remove(event);

    final minimized = List<EventPost>.from(state.minimizedEvents);

    if (!minimized.contains(event)) {
      minimized.add(event);
    }

    emit(state.copyWith(
      openEvents: open,
      minimizedEvents: minimized,
      selectedEvent: null,
    ));
  }

  void restore(EventPost event) {
    final minimized = List<EventPost>.from(state.minimizedEvents)
      ..remove(event);

    final open = List<EventPost>.from(state.openEvents);

    if (!open.contains(event)) {
      open.add(event);
    }

    emit(state.copyWith(
      minimizedEvents: minimized,
      openEvents: open,
      selectedEvent: event,
    ));
  }

  void dismiss(EventPost event) {
    final open = List<EventPost>.from(state.openEvents)
      ..remove(event);

    final minimized = List<EventPost>.from(state.minimizedEvents)
      ..remove(event);

    emit(state.copyWith(
      openEvents: open,
      minimizedEvents: minimized,
      selectedEvent:
          state.selectedEvent == event ? null : state.selectedEvent,
    ));
  }

  void minimizeAll() {
    final updated = List<EventPost>.from(state.minimizedEvents);

    if (state.selectedEvent != null &&
        !updated.contains(state.selectedEvent)) {
      updated.add(state.selectedEvent!);
    }

    emit(state.copyWith(
      minimizedEvents: updated,
      selectedEvent: null,
    ));
  }

  void minimizeAllIfNeeded() {
    if (state.openEvents.isEmpty && state.minimizedEvents.isEmpty) {
      return;
    }

    final updated = List<EventPost>.from(state.minimizedEvents);

    for (final event in state.openEvents) {
      if (!updated.contains(event)) {
        updated.add(event);
      }
    }

    emit(state.copyWith(
      minimizedEvents: updated,
      openEvents: [],
      selectedEvent: null,
    ));
  }
}