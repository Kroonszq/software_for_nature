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
    emit(state.copyWith(loading: true));

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

    emit(state.copyWith(events: events, loading: false));
  }

  void _onTimeWindowChanged(
    HybridTimeWindowChanged event,
    Emitter<HybridState> emit,
  ) {
    final current = state;

    final filtered = current.events.where((e) {
      return event.window.contains(e.startDuration);
    }).toList();

    emit(current.copyWith(timeWindow: event.window, events: filtered));
  }
}
