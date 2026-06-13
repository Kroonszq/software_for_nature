import 'package:bloc/bloc.dart';
import '../../../data/models/event_post.dart';

part 'minimized_events_event.dart';
part 'minimized_events_state.dart';


class MinimizedEventsBloc extends Bloc<MinimizedEventsEvent, MinimizedEventsState> {

  MinimizedEventsBloc() : super(const MinimizedEventsState()) {

    // When event is opened
    on<OpenEvent>((event, emit) {
      final alreadyOpen = state.openEvents.any((e) => e.id == event.post.id);
      emit(
        MinimizedEventsState(
          openEvents: alreadyOpen ? state.openEvents : [...state.openEvents, event.post],
          minimized: state.minimized.where((e) => e.id != event.post.id).toList(),
        ),
      );
    });

    // When event is minimized
    on<MinimizeEvent>((event, emit) {
      final alreadyMinimized = state.minimized.any((e) => e.id == event.post.id);
      emit(
        MinimizedEventsState(
          openEvents: state.openEvents.where((e) => e.id != event.post.id).toList(),
          minimized: alreadyMinimized ? state.minimized : [...state.minimized, event.post],
        ),
      );
    });

    // When a event is closed
    on<CloseEvent>((event, emit) {
      emit(
        MinimizedEventsState(
          openEvents: state.openEvents.where((e) => e.id != event.post.id).toList(),
          minimized: state.minimized.where((e) => e.id != event.post.id).toList(),
        ),
      );
    });

  // When the drawer is clicked away when event are active within th edrawer
    on<MinimizeAllOpen>((event, emit) {
      final toAdd = state.openEvents.where((o) => !state.minimized.any((m) => m.id == o.id));
      emit(
        MinimizedEventsState(
          openEvents: const [],
          minimized: [...state.minimized, ...toAdd],
        ),
      );
    });

    // When on cleared all events
    on<ClearMinimizedEvents>((event, emit) {
      emit(MinimizedEventsState(openEvents: state.openEvents));
    });
  }
}
