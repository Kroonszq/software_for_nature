import 'package:bloc/bloc.dart';
import 'package:software_for_nature/data/models/geobounds.dart';
import '../../../data/models/event_post.dart';
import '../../../data/repositories/event_post_repository.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final EventPostRepository repository;

  MapBloc(this.repository) : super(MapInitial()) {
    on<LoadMapEvents>(_onLoad);
    on<UpdateMapBounds>(_onBoundsUpdated);
  }

  Future<void> _onLoad(
    LoadMapEvents event,
    Emitter<MapState> emit,
  ) async {
    emit(MapLoading());

    final posts = await repository.getEventPosts();

    final mapPosts = posts
        .where((e) => e.coordinates != null)
        .toList();

    emit(MapLoaded(
      posts: mapPosts,
      visiblePosts: mapPosts, // initially everything visible
      bounds: null,
    ));
  }

  Future<void> _onBoundsUpdated(
    UpdateMapBounds event,
    Emitter<MapState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MapLoaded) return;

    final filtered = currentState.posts.where((post) {
      final coords = post.coordinates;
      if (coords == null) return false;

      return event.bounds.contains(coords);
    }).toList();

    emit(MapLoaded(
      posts: currentState.posts,
      visiblePosts: filtered,
      bounds: event.bounds,
    ));
  }
}