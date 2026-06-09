part of 'map_bloc.dart';


sealed class MapState {}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final List<EventPost> posts;
  final List<EventPost> visiblePosts;
  final GeoBounds? bounds;

  final TimeWindow? timeWindow;

  MapLoaded({
    required this.posts,
    required this.visiblePosts,
    this.bounds,
    this.timeWindow,
  });

  MapLoaded copyWith({
    List<EventPost>? posts,
    List<EventPost>? visiblePosts,
    GeoBounds? bounds,
    TimeWindow? timeWindow,
  }) {
    return MapLoaded(
      posts: posts ?? this.posts,
      visiblePosts: visiblePosts ?? this.visiblePosts,
      bounds: bounds ?? this.bounds,
      timeWindow: timeWindow ?? this.timeWindow,
    );
  }
}