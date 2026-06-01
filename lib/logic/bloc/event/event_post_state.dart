import '../../../data/models/event_post.dart';

sealed class EventPostState {}

class EventPostInitial extends EventPostState {}

class EventPostLoading extends EventPostState {}

class EventPostLoaded extends EventPostState {
  final List<EventPost> posts;
  final EventPost? selectedPost;

  EventPostLoaded(
    this.posts, {
    this.selectedPost,
  });

  EventPostLoaded copyWith({
    List<EventPost>? posts,
    EventPost? selectedPost,
  }) {
    return EventPostLoaded(
      posts ?? this.posts,
      selectedPost: selectedPost ?? this.selectedPost,
    );
  }
}

class EventPostError extends EventPostState {
  final String message;

  EventPostError(this.message);
}