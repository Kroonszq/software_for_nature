part of 'timeline_bloc.dart';

sealed class TimelineState {}

class TimelineInitial extends TimelineState {
  EventPost? selectedPost;

  /// Bumped every time an external source (e.g. a map marker) asks the timeline
  /// to scroll to [selectedPost]. A plain hover/select does not change it, so
  /// listeners can scroll only on an explicit focus request.
  final int focusRequestId;

  TimelineInitial({this.selectedPost, this.focusRequestId = 0});

  TimelineInitial copyWith({EventPost? selectedPost, int? focusRequestId}) {
    return TimelineInitial(
      selectedPost: selectedPost,
      focusRequestId: focusRequestId ?? this.focusRequestId,
    );
  }
}
