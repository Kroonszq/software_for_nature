import '../../../data/models/event_post.dart';

sealed class EventPostEvent {}

class LoadEventPosts extends EventPostEvent {}

class SelectEventPost extends EventPostEvent {
  final EventPost post;

  SelectEventPost(this.post);
}