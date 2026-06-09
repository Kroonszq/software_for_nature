import 'package:bloc/bloc.dart';
import 'event_selection_event.dart';
import 'event_selection_state.dart';
import 'package:software_for_nature/data/models/event_post.dart';

class EventSelectionBloc
    extends Bloc<EventSelectionEvent, EventSelectionState> {
  EventSelectionBloc() : super(const EventSelectionState()) {
    on<HoverEvent>(_onHover);
    on<SelectEvent>(_onSelect);
    on<CloseEvent>(_onClose);
    on<MinimizeEvent>(_onMinimize);
    on<RestoreEvent>(_onRestore);
  }

  void _onHover(HoverEvent event, Emitter<EventSelectionState> emit) {
    emit(state.copyWith(hovered: event.event));
  }

  void _onSelect(SelectEvent event, Emitter<EventSelectionState> emit) {
    final updated = List<EventPost>.from(state.selected);

    if (!updated.contains(event.event)) {
      updated.add(event.event);
    }

    emit(state.copyWith(selected: updated));
  }

  void _onClose(CloseEvent event, Emitter<EventSelectionState> emit) {
    final selected = List<EventPost>.from(state.selected);
    final minimized = List<EventPost>.from(state.minimized);

    selected.remove(event.event);
    minimized.remove(event.event);

    emit(state.copyWith(
      selected: selected,
      minimized: minimized,
    ));
  }

  void _onMinimize(MinimizeEvent event, Emitter<EventSelectionState> emit) {
    final selected = List<EventPost>.from(state.selected);
    final minimized = List<EventPost>.from(state.minimized);

    selected.remove(event.event);
    if (!minimized.contains(event.event)) {
      minimized.add(event.event);
    }

    emit(state.copyWith(
      selected: selected,
      minimized: minimized,
    ));
  }

  void _onRestore(RestoreEvent event, Emitter<EventSelectionState> emit) {
    final selected = List<EventPost>.from(state.selected);
    final minimized = List<EventPost>.from(state.minimized);

    minimized.remove(event.event);
    if (!selected.contains(event.event)) {
      selected.add(event.event);
    }

    emit(state.copyWith(
      selected: selected,
      minimized: minimized,
    ));
  }
}