import 'package:bloc/bloc.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/geobounds.dart';
import 'package:software_for_nature/data/models/event_query.dart';
import '../../../data/repositories/event_post_repository.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final EventPostRepository repository;

  GeoBounds? _currentBounds;

  MapBloc(this.repository) : super(MapInitial()) {
    on<LoadMapEvents>(_onLoad);
    on<UpdateMapBounds>(_onBoundsUpdated);
  }

  Future<void> _onLoad(
    LoadMapEvents event,
    Emitter<MapState> emit,
  ) async {
    emit(MapLoading());

    final posts = await repository.queryEvents(
      const EventQuery(),
    );

    final mapPosts = posts.where((e) => e.coordinates != null).toList();

    emit(MapLoaded(
      posts: mapPosts,
      visiblePosts: mapPosts,
      bounds: null,
    ));
  }

  Future<void> _onBoundsUpdated(
    UpdateMapBounds event,
    Emitter<MapState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MapLoaded) return;

    _currentBounds = event.bounds;

    emit(MapLoading());

    final posts = await repository.queryEvents(
      EventQuery(bounds: _currentBounds),
    );

    final mapPosts = posts.where((e) => e.coordinates != null).toList();

    emit(MapLoaded(
      posts: mapPosts,
      visiblePosts: mapPosts,
      bounds: _currentBounds,
    ));
  }
}