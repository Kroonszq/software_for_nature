part of 'map_bloc.dart';

sealed class MapState {}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final List<EventPost> posts;
  final EventPost? selectedPost;

  MapLoaded(this.posts, {this.selectedPost});

  MapLoaded copyWith({
    List<EventPost>? posts,
    EventPost? selectedPost,
  }) {
    return MapLoaded(
      posts ?? this.posts,
      selectedPost: selectedPost ?? this.selectedPost,
    );
  }
}