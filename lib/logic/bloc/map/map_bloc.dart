import 'package:bloc/bloc.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/geobounds.dart';
import 'package:software_for_nature/data/models/event_query.dart';
import 'package:software_for_nature/data/models/time_window.dart';
import '../../../data/repositories/event_post_repository.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final EventPostRepository repository;

  List<EventPost> _allPosts = [];

  GeoBounds? _currentBounds;
  TimeWindow? _currentWindow;

  MapBloc(this.repository) : super(MapInitial()) {
    on<LoadMapEvents>(_onLoad);
    on<UpdateMapBounds>(_onBoundsUpdated);
    on<UpdateTimeWindow>(_onTimeWindowChanged);
  }

  Future<void> _onLoad(
    LoadMapEvents event,
    Emitter<MapState> emit,
  ) async {
    emit(MapLoading());

    _allPosts = await repository.queryEvents(const EventQuery());

    _emitFiltered(emit);
  }

  Future<void> _onBoundsUpdated(
    UpdateMapBounds event,
    Emitter<MapState> emit,
  ) async {
    _currentBounds = event.bounds;
    _emitFiltered(emit);
  }

  void _onTimeWindowChanged(
    UpdateTimeWindow event,
    Emitter<MapState> emit,
  ) {
    _currentWindow = event.window;
    _emitFiltered(emit);
  }

  void _emitFiltered(Emitter<MapState> emit) {
    final filtered = _allPosts.where((post) {
      final coords = post.coordinates;
      if (coords == null) return false;

      final inBounds = _currentBounds == null
          ? true
          : _currentBounds!.contains(coords);

      final inTime = _currentWindow == null
          ? true
          : _currentWindow!.contains(post.startDuration);

      return inBounds && inTime;
    }).toList();

    emit(MapLoaded(
      posts: _allPosts,
      visiblePosts: filtered,
      bounds: _currentBounds,
      timeWindow: _currentWindow,
    ));
  }
}