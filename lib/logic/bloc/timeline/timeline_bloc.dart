import 'package:bloc/bloc.dart';
import '../../../data/models/event_post.dart';
import '../../../data/repositories/event_post_repository.dart';

part 'timeline_event.dart';
part 'timeline_state.dart';

class TimelineBloc extends Bloc<TimelineEvent, TimelineState> {
  final EventPostRepository repository;

  TimelineBloc(this.repository) : super(TimelineInitial()) {
    on<LoadTimelineEvents>(_onLoadTimelineEvents);
    on<SelectTimelineEvent>(_onSelectTimelineEvent);
  }

  Future<void> _onLoadTimelineEvents(
    LoadTimelineEvents event,
    Emitter<TimelineState> emit,
  ) async {
    emit(TimelineLoading());

    final posts = await repository.getEventPosts();

    // sort by time (newest first)
    posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    emit(TimelineLoaded(posts));
  }

  void _onSelectTimelineEvent(
    SelectTimelineEvent event,
    Emitter<TimelineState> emit,
  ) {
    final current = state;

    if (current is TimelineLoaded) {
      emit(current.copyWith(selectedPost: event.post));
    }
  }
}