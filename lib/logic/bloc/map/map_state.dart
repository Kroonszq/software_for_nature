part of 'map_bloc.dart';


sealed class MapState {}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final List<EventPost> posts;
  final EventPost? selectedPost;
  final List<EventPost> visiblePosts;
  final GeoBounds? bounds;


  MapLoaded({
    required this.posts,
    required this.visiblePosts,
    this.bounds,
    this.selectedPost,
  }); //note that posts here is already filtered to have only posts with coordinates, in map_bloc.dart

   MapLoaded copyWith({
    List<EventPost>? posts,
    List<EventPost>? visiblePosts,
    GeoBounds? bounds,
    EventPost? selectedPost,
  }) {
    return MapLoaded(
      posts: posts ?? this.posts,
      visiblePosts: visiblePosts ?? this.visiblePosts,
      bounds: bounds ?? this.bounds,
      selectedPost: selectedPost ?? this.selectedPost,
    );
  }
}