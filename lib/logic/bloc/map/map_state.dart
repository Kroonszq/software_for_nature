part of 'map_bloc.dart';


sealed class MapState {}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final List<EventPost> posts;
  final List<EventPost> visiblePosts;
  final GeoBounds? bounds;

  final TimeWindow? timeWindow;
  final EventPost? earliest;  
  final EventPost? latest;  

  MapLoaded({
    required this.posts,
    required this.visiblePosts,
    this.bounds,
    this.timeWindow,
    this.earliest,
    this.latest
  });

  MapLoaded copyWith({
    List<EventPost>? posts,
    List<EventPost>? visiblePosts,
    GeoBounds? bounds,
    TimeWindow? timeWindow,
    EventPost? earliest,
    EventPost? latest
  }) {
    return MapLoaded(
      posts: posts ?? this.posts,
      visiblePosts: visiblePosts ?? this.visiblePosts,
      bounds: bounds ?? this.bounds,
      timeWindow: timeWindow ?? this.timeWindow,
      earliest: earliest ?? this.earliest,
      latest: latest ?? this.latest
    );
  }
}