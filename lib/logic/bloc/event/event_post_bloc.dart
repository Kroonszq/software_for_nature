import 'package:bloc/bloc.dart';
import 'package:software_for_nature/data/repositories/event_post_repository.dart';
import 'event_post_event.dart';
import 'event_post_state.dart';

class EventPostBloc extends Bloc<EventPostEvent, EventPostState> {
  final EventPostRepository repository;

  EventPostBloc(this.repository) : super(EventPostInitial()) {
    on<LoadEventPosts>(_onLoad);
    on<SelectEventPost>(_onSelect);
  }

  Future<void> _onLoad(
    LoadEventPosts event,
    Emitter<EventPostState> emit,
  ) async {
    emit(EventPostLoading());

    try {
      final posts = await repository.getEventPosts();
      emit(EventPostLoaded(posts));
    } catch (e) {
      emit(EventPostError(e.toString()));
    }
  }

  void _onSelect(
    SelectEventPost event,
    Emitter<EventPostState> emit,
  ) {
    final current = state;

    if (current is EventPostLoaded) {
      emit(current.copyWith(selectedPost: event.post));
    }
  }
}