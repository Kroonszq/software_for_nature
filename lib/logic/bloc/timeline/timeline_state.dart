part of 'timeline_bloc.dart';

sealed class TimelineState {}

class TimelineInitial extends TimelineState{
  EventPost? selectedPost;

  TimelineInitial({
    this.selectedPost,
  });

  TimelineInitial copyWith({
    EventPost? selectedPost,
  }) {
    return TimelineInitial(
      selectedPost: selectedPost,
    );
  }

}
