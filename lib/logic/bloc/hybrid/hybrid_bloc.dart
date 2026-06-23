import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/geobounds.dart';
import 'package:software_for_nature/data/models/event_query.dart';
import 'package:software_for_nature/data/models/time_window.dart';
import 'package:software_for_nature/data/repositories/event_post_repository.dart';

part 'hybrid_event.dart';
part 'hybrid_state.dart';

class HybridBloc extends Bloc<HybridEvent, HybridState> {
  final EventPostRepository repository;

  HybridBloc(this.repository) : super(const HybridState(events: [])) {
    on<HybridBoundsChanged>(_onBoundsChanged);
    on<HybridTimeRangeChanged>(_onTimeRangeChanged);
    // Restart so a newer filter (e.g. clearing the search) cancels any
    // in-flight stale fetch and always wins.
    on<HybridFilterChanged>(_onFilterChanged, transformer: restartable());
    on<HybridVisibleCategoriesChanged>(_onVisibleCategoriesChanged);
    on<HybridEventSelected>(_onSelected);
    on<HybridReloadRequested>(_onReload);
    on<HybridTimeWindowChanged>(_onTimeWindowChanged);

    add(HybridReloadRequested());
  }

  GeoBounds? _bounds;
  DateTimeRange? _timeRange;
  TimeWindow? _timeWindow;


  Set<String>? _categoryIds;
  Set<String>? _tagLabels;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _search;

  Set<String>? _visibleCategoryIds;

  Future<void> _onReload(
    HybridReloadRequested event,
    Emitter<HybridState> emit,
  ) async {
    await _fetch(emit);
  }

  Future<void> _onBoundsChanged(
    HybridBoundsChanged event,
    Emitter<HybridState> emit,
  ) async {
    _bounds = event.bounds;
    await _fetch(emit);
  }

  Future<void> _onTimeRangeChanged(
    HybridTimeRangeChanged event,
    Emitter<HybridState> emit,
  ) async {
    _timeRange = event.range;
    await _fetch(emit);
  }

  Future<void> _onFilterChanged(
    HybridFilterChanged event,
    Emitter<HybridState> emit,
  ) async {
    _categoryIds = (event.categoryIds == null || event.categoryIds!.isEmpty)
        ? null
        : event.categoryIds;
    _tagLabels = (event.tagLabels == null || event.tagLabels!.isEmpty)
        ? null
        : event.tagLabels;
    _startDate = event.startDate;
    _endDate = event.endDate;
    _search = (event.search == null || event.search!.trim().isEmpty)
        ? null
        : event.search;
    // If an explicit start/end were provided via the filter, reflect them
    // in the bloc's public `timeRange` state so consumers (e.g. markers)
    // can render duration UI based on the active date range.
    if (_startDate != null && _endDate != null) {
      _timeRange = DateTimeRange(start: _startDate!, end: _endDate!);
    } else {
      _timeRange = null;
    }

    await _fetch(emit);
  }

  Future<void> _onVisibleCategoriesChanged(
    HybridVisibleCategoriesChanged event,
    Emitter<HybridState> emit,
  ) async {
    _visibleCategoryIds = event.categoryIds;
    await _fetch(emit);
  }

  void _onSelected(HybridEventSelected event, Emitter<HybridState> emit) {
    emit(state.copyWith(selectedEvent: event.event));
  }

  Future<void> _fetch(Emitter<HybridState> emit) async {
    emit(state.copyWith(loading: true, timeRange: _timeRange, timeWindow: _timeWindow));

    // The timeline's visible categories (when known) are the authoritative scope
    final Set<String>? categoryScope =
        _visibleCategoryIds ?? _categoryIds;

    // An explicit empty scope means nothing is visible: show no markers
    if (categoryScope != null && categoryScope.isEmpty) {
      emit(state.copyWith(events: const [], loading: false));
      return;
    }

    final events = await repository.queryEvents(
      EventQuery(
        bounds: _bounds,
        timeRange: _timeRange,
        categoryIds: categoryScope,
        startDate: _startDate,
        endDate: _endDate,
        search: _search,
        tagLabels: _tagLabels,
      ),
    );

    // If no explicit timeRange was provided (e.g. no date filter selected),
    // set the visible range to fit all returned events
    if (_timeRange == null && events.isNotEmpty) {
      final earliest = events.reduce((a, b) =>
          a.startDuration.isBefore(b.startDuration) ? a : b);
      final latest = events.reduce(
          (a, b) => a.endDuration.isAfter(b.endDuration) ? a : b);
      _timeRange = DateTimeRange(start: earliest.startDuration, end: latest.endDuration);
    }

    // Ensure there's a TimeWindow (used by cluster markers). Prefer an
    // explicitly set timeWindow (from timeline interactions), otherwise
    // construct one from the current _timeRange.
    if (_timeWindow == null && _timeRange != null) {
      _timeWindow = TimeWindow(start: _timeRange!.start, end: _timeRange!.end);
    }

    emit(state.copyWith(events: events, loading: false, timeRange: _timeRange, timeWindow: _timeWindow));
  }

  void _onTimeWindowChanged(
    HybridTimeWindowChanged event,
    Emitter<HybridState> emit,
  ) {
    final current = state;

    // Keep the private copy in sync so future emits include it.
    _timeWindow = event.window;

    final filtered = current.events.where((e) {
      return event.window.contains(e.startDuration);
    }).toList();

    emit(current.copyWith(timeWindow: event.window, events: filtered));
  }
}
