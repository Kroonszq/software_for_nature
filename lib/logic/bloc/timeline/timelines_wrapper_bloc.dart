import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:software_for_nature/data/models/category.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/event_query.dart';
import 'package:software_for_nature/logic/services/interfaces/category_service_interface.dart';
import 'package:software_for_nature/presentation/models/timeline.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_content.dart';

part 'timelines_wrapper_event.dart';
part 'timelines_wrapper_state.dart';

class TimeLinesWrapperBloc extends Bloc<TimeLinesWrapperEvent, TimeLinesWrapperState> {
  final CategoryServiceInterface _categoryService;

  List<Category> _activeCategories = const [];
  Set<String> _tagLabels = const {};
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

  TimeLinesWrapperBloc({required this._categoryService}) : super(TimeLinesWrapperInitial()) {

    on<FilterChanged>((event, emit) async {
      _activeCategories = event.activeCategories;
      _tagLabels = event.tagLabels;
      _startDate = event.startDate;
      _endDate = event.endDate;
      _searchQuery = event.searchQuery;

      await _loadTimelines(emit);
    }, transformer: restartable());

    on<LoadTimelineEvents>((event, emit) async => await _loadTimelines(emit));
    on<SetTimelineFullscreen>((event, emit) => _toggleTimelineFullscreen(event.timelineHash, emit));
    on<SetTimelineActive>((event, emit) => _toggleTimelineActive(event.timelineHash, true, emit));
    on<SetTimelineInActive>((event, emit) => _toggleTimelineActive(event.timelineHash, false, emit));
    on<ReorderTimeline>((event, emit) => _reOrderTimeline(event.oldIndex, event.newIndex, emit));
    add(LoadTimelineEvents());
  }

  Future<void> _loadTimelines(Emitter<TimeLinesWrapperState> emit) async {
    final activeIds = _activeCategories.map((c) => c.id).toSet();
    final categories = await _categoryService.getCategories(
      EventQuery(
        categoryIds: activeIds,
        startDate: _startDate,
        endDate: _endDate,
        search: _searchQuery,
        tagLabels: _tagLabels,
      ),
    );

    Map<int, Timeline> grouppedEvents = {};
    for (final category in categories) {
      if (!grouppedEvents.containsKey(category.name.hashCode)) {
        var timeline = Timeline(
          title: category.name,
          color: category.color,
          events: category.events,
          active: true,
          fullscreen: false,
          timelineWidget: null,
        );

        grouppedEvents[category.name.hashCode] = timeline;
      }
    }

    Map<int, ScrollController> timelineScrollers = {};

    // Foreach category create a timeline
    for (final categoryEntry in grouppedEvents.entries) {
      final timeline = TimelineContent(
        listOfEvents: categoryEntry.value.events,
        groupColor: categoryEntry.value.color,
      );

      grouppedEvents[categoryEntry.key]!.timelineWidget = timeline;
      timelineScrollers[categoryEntry.key] = ScrollController();
    }

    emit(
      TimeLinesWrapperLoaded(
        timelines: grouppedEvents,
        timelineScrollers: timelineScrollers,
        axisScrollController: ScrollController(),
        timelineOrder: grouppedEvents.keys.toList(),
      ),
    );
  }

  void _reOrderTimeline(int oldIndex, int newIndex, Emitter<TimeLinesWrapperState> emit){
    if (state is! TimeLinesWrapperLoaded) {
      return;
    }
    final current = state as TimeLinesWrapperLoaded;

    final newOrder = List<int>.from(current.timelineOrder);
    final item = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, item);

    emit(current.copyWith(timelineOrder: newOrder));
  }

  void _toggleTimelineActive(int timelineHash, bool value, Emitter<TimeLinesWrapperState> emit){
     if (state is! TimeLinesWrapperLoaded) {
        return;
      }

      final current = state as TimeLinesWrapperLoaded;
      final timeline = current.timelines[timelineHash];

      if (timeline == null) {
        return;
      }

      if(value && timeline.active || !value && !timeline.active){
        return;
      }

      final updatedTimelines = Map<int, Timeline>.from(current.timelines);

      timeline.active = value;
      updatedTimelines[timelineHash] = timeline;

      emit(current.copyWith(timelines: updatedTimelines));
  }

  void _toggleTimelineFullscreen(int timelineHash, Emitter<TimeLinesWrapperState> emit){
      if (state is! TimeLinesWrapperLoaded) {
        return;
      }

      final current = state as TimeLinesWrapperLoaded;

      final timeline = current.timelines[timelineHash];
      if (timeline == null) {
        return;
      }

      final updatedTimelines = Map<int, Timeline>.from(current.timelines);

      // Flip so pressing the icon expands, and pressing again reverts.
      timeline.fullscreen = !timeline.fullscreen;
      updatedTimelines[timelineHash] = timeline;

      emit(current.copyWith(timelines: updatedTimelines));

  }
}
