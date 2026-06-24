part of 'timeline_bloc.dart';

sealed class TimelineState {}

class TimelineInitial extends TimelineState {
  EventPost? selectedPost;

  final int focusRequestId;

  TimelineInitial({this.selectedPost, this.focusRequestId = 0});

  TimelineInitial copyWith({EventPost? selectedPost, int? focusRequestId}) {
    return TimelineInitial(
      selectedPost: selectedPost,
      focusRequestId: focusRequestId ?? this.focusRequestId,
    );
  }
}
