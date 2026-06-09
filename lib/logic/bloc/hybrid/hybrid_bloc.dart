import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/geobounds.dart';
import 'package:software_for_nature/data/models/event_query.dart';
import 'package:software_for_nature/data/repositories/event_post_repository.dart';

part 'hybrid_event.dart';
part 'hybrid_state.dart';

class HybridBloc extends Bloc<HybridEvent, HybridState> {
  final EventPostRepository repository;

  HybridBloc(this.repository)
      : super(const HybridState(events: [])) {
    on<HybridBoundsChanged>(_onBoundsChanged);
    on<HybridTimeRangeChanged>(_onTimeRangeChanged);
    on<HybridEventSelected>(_onSelected);
    on<HybridReloadRequested>(_onReload);

    add(HybridReloadRequested());
  }

  GeoBounds? _bounds;
  DateTimeRange? _timeRange;

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

  void _onSelected(
    HybridEventSelected event,
    Emitter<HybridState> emit,
  ) {
    emit(state.copyWith(selectedEvent: event.event));
  }

  Future<void> _fetch(Emitter<HybridState> emit) async {
    emit(state.copyWith(loading: true));

    final events = await repository.queryEvents(
      EventQuery(
        bounds: _bounds,
        timeRange: _timeRange,
      ),
    );

    emit(
      state.copyWith(
        events: events,
        loading: false,
      ),
    );
  }
}