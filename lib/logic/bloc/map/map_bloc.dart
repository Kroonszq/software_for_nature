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
  List<EventPost> _scopedPosts = [];

  late EventPost earliest;
  late EventPost latest;

  GeoBounds? _currentBounds;
  late TimeWindow _currentWindow;

  // active filter constraints
  Set<String>? _categoryIds;
  Set<String>? _tagLabels;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _search;

  MapBloc(this.repository) : super(MapInitial()) {
    on<LoadMapEvents>(_onLoad);
    on<UpdateMapBounds>(_onBoundsUpdated);
    on<UpdateTimeWindow>(_onTimeWindowChanged);
    on<MapFilterChanged>(_onFilterChanged);
  }

  Future<void> _onLoad(LoadMapEvents event, Emitter<MapState> emit) async {
    emit(MapLoading());

    final results = await Future.wait([
      repository.queryEvents(const EventQuery()),
      repository.getEarliestEvent(),
      repository.getLatestEvent(),
    ]);

    _allPosts = results[0] as List<EventPost>;
    _scopedPosts = _allPosts;
    earliest = results[1] as EventPost;
    latest = results[2] as EventPost;

    _currentWindow = TimeWindow(
      start: earliest.startDuration,
      end: latest.endDuration,
    );

    _emitFiltered(emit);
  }

  Future<void> _onFilterChanged(MapFilterChanged event, Emitter<MapState> emit ) async {

    if (event.categoryIds != null && event.categoryIds!.isNotEmpty) {
      _categoryIds = event.categoryIds;
    } else {
      _categoryIds = null;
    }

    if (event.tagLabels != null && event.tagLabels!.isNotEmpty) {
      _tagLabels = event.tagLabels;
    } else {
      _tagLabels = null;
    }

    if (event.search != null && event.search!.trim().isNotEmpty) {
      _search = event.search;
    } else {
      _search = null;
    }

    _startDate = event.startDate;
    _endDate = event.endDate;

    _scopedPosts = await repository.queryEvents(
      EventQuery(
        categoryIds: _categoryIds,
        tagLabels: _tagLabels,
        startDate: _startDate,
        endDate: _endDate,
        search: _search,
      ),
    );

    _emitFiltered(emit);
  }

  void _onBoundsUpdated(UpdateMapBounds event, Emitter<MapState> emit) {
    _currentBounds = event.bounds;
    _emitFiltered(emit);
  }

  void _onTimeWindowChanged(UpdateTimeWindow event, Emitter<MapState> emit) {
    _currentWindow = event.window;
    _emitFiltered(emit);
  }

  void _emitFiltered(Emitter<MapState> emit) {
    final filtered = _scopedPosts.where((post) {

      final coords = post.coordinates;
      if (coords == null){ 
        return false;
      }


      final inBounds = _currentBounds?.contains(coords) ?? true;
      final inTime = _currentWindow.contains(post.startDuration);

      return inBounds && inTime;
    }).toList();

    emit(MapLoaded(
      posts: _scopedPosts,
      visiblePosts: filtered,
      bounds: _currentBounds,
      timeWindow: _currentWindow,
      earliest: earliest,
      latest: latest,
    ));
  }
}