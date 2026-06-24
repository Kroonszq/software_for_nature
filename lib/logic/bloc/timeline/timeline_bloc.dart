import 'package:bloc/bloc.dart';
import '../../../data/models/event_post.dart';

part 'timeline_event.dart';
part 'timeline_state.dart';

class TimelineBloc extends Bloc<TimelineEvent, TimelineState> {
  TimelineBloc() : super(TimelineInitial()) {
    on<SelectTimelineEvent>(_onSelectTimelineEvent);

    on<FocusTimelineEvent>((event, emit) {
      final current = state;

      if (current is TimelineInitial) {
        emit(
          current.copyWith(
            selectedPost: event.post,
            focusRequestId: current.focusRequestId + 1,
          ),
        );
      }
    });

    on<UnSelectTimelineEvent>((event, emit) {
      final current = state;

      if (current is TimelineInitial) {
        emit(current.copyWith(selectedPost: null));
      }
    });
  }

  void _onSelectTimelineEvent(SelectTimelineEvent event, Emitter<TimelineState> emit) {
    final current = state;

    if (current is TimelineInitial) {
      emit(current.copyWith(selectedPost: event.post));
    }
  }
}
