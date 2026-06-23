import 'package:bloc/bloc.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/geobounds.dart';
import 'package:software_for_nature/data/models/event_query.dart';
import 'package:software_for_nature/data/models/time_window.dart';
import 'package:software_for_nature/data/repositories/event_post_repository.dart';
import 'package:software_for_nature/logic/bloc/hybrid/hybrid_state.dart';

part 'hybrid_event.dart';

class HybridBloc extends Bloc<HybridEvent, HybridState> {
  final EventPostRepository repository;


  HybridBloc(this.repository) : super(HybridState(events: const [], timeWindow: TimeWindow(start: DateTime.now(), end: DateTime.now()))) {
    on<HybridBoundsChanged>(_onBoundsChanged);
    on<HybridFilterChanged>(_onFilterChanged);
    on<HybridVisibleGroupsChanged>(_onVisibleGroupsChanged);
    on<HybridEventSelected>(_onSelected);
    on<HybridReloadRequested>(_onReload);
    on<HybridTimeWindowChanged>(_onTimeWindowChanged);

    add(HybridReloadRequested());
  }

  GeoBounds? _bounds;
  TimeWindow? _currentWindow;

  Set<String>? _groupIds;
  Set<String>? _tagLabels;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _search;

  Set<String>? _visibleGroupIds;

  Future<void> _onReload(
    HybridReloadRequested event,
    Emitter<HybridState> emit,
  ) async {
    emit(state.copyWith(loading: true));

    final events = await repository.queryEvents(const EventQuery());

    if (events.isEmpty) {
      _currentWindow = TimeWindow(
        start: DateTime.now(),
        end: DateTime.now(),
      );
    } else {
      final start = events
          .map((e) => e.startDuration)
          .reduce((a, b) => a.isBefore(b) ? a : b);

      final end = events
          .where((e) => e.endDuration != null)
          .map((e) => e.endDuration!)
          .reduce((a, b) => a.isAfter(b) ? a : b);

      _currentWindow = TimeWindow(start: start, end: end);
    }

    emit(state.copyWith(timeWindow: _currentWindow));

    await _fetch(emit);
  }

  Future<void> _onBoundsChanged(
    HybridBoundsChanged event,
    Emitter<HybridState> emit,
  ) async {
    _bounds = event.bounds;
    await _fetch(emit);
  }


  Future<void> _onFilterChanged(
    HybridFilterChanged event,
    Emitter<HybridState> emit,
  ) async {
    _groupIds = (event.groupIds == null || event.groupIds!.isEmpty)
        ? null
        : event.groupIds;
    _tagLabels = (event.tagLabels == null || event.tagLabels!.isEmpty)
        ? null
        : event.tagLabels;
    _startDate = event.startDate;
    _endDate = event.endDate;
    _search = (event.search == null || event.search!.trim().isEmpty)
        ? null
        : event.search;
    await _fetch(emit);
  }

  Future<void> _onVisibleGroupsChanged(
    HybridVisibleGroupsChanged event,
    Emitter<HybridState> emit,
  ) async {
    _visibleGroupIds = event.groupIds;
    await _fetch(emit);
  }

  void _onSelected(HybridEventSelected event, Emitter<HybridState> emit) {
    emit(state.copyWith(selectedEvent: event.event));
  }

  Future<void> _fetch(Emitter<HybridState> emit) async {
    emit(state.copyWith(loading: true));

    final Set<String>? groupScope = _visibleGroupIds ?? _groupIds;

    if (groupScope != null && groupScope.isEmpty) {
      emit(state.copyWith(events: const [], loading: false));
      return;
    }

    final events = await repository.queryEvents(
      EventQuery(
        bounds: _bounds,
        timeWindow: _currentWindow,
        groupIds: groupScope,
        startDate: _startDate,
        endDate: _endDate,
        search: _search,
        tagLabels: _tagLabels,
      ),
    );

    emit(state.copyWith(
      events: events,
      timeWindow: _currentWindow,
      loading: false,
    ));
  }

  Future<void> _onTimeWindowChanged(
    HybridTimeWindowChanged event,
    Emitter<HybridState> emit,
  ) async {
    _currentWindow = event.window;
    await _fetch(emit);
  }
}
