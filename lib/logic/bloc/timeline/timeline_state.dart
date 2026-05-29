part of 'timeline_bloc.dart';

sealed class TimelineState {}

class TimelineInitial extends TimelineState {}

class TimelineLoading extends TimelineState {}

class TimelineLoaded extends TimelineState {
  final List<EventPost> posts;
  final EventPost? selectedPost;

  TimelineLoaded(this.posts, {this.selectedPost});

  TimelineLoaded copyWith({
    List<EventPost>? posts,
    EventPost? selectedPost,
  }) {
    return TimelineLoaded(
      posts ?? this.posts,
      selectedPost: selectedPost ?? this.selectedPost,
    );
  }
}