import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/group.dart';
import 'package:software_for_nature/data/models/timeline.dart';
import 'package:software_for_nature/data/models/user.dart';
import 'package:software_for_nature/data/repositories/event_post_repository.dart';
import 'package:software_for_nature/data/repositories/interfaces/group_repository_interface.dart';
import 'package:software_for_nature/data/repositories/interfaces/user_repository_interface.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_column.dart';

part 'timelines_wrapper_event.dart';
part 'timelines_wrapper_state.dart';

class TimeLinesWrapperBloc extends Bloc<TimeLinesWrapperEvent, TimeLinesWrapperState> {
  final EventPostRepository _eventPostRepository;
  final GroupRepositoryInterface _groupRepository;
  final UserRepositoryInterface _userRepository;

  // Current filter criteria. Updated whenever a [FilterChanged] event arrives.
  List<Group> _activeGroups = const [];
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

  TimeLinesWrapperBloc({ required this._eventPostRepository, required this._groupRepository, required this._userRepository } ) : super(TimeLinesWrapperInitial()) {

    on<LoadTimelineEvents>((event, emit) async {
      await _loadTimelines(emit);
    });

    on<FilterChanged>((event, emit) async {
      _activeGroups = event.activeGroups;
      _startDate = event.startDate;
      _endDate = event.endDate;
      _searchQuery = event.searchQuery;

      await _loadTimelines(emit);
    });

    on<SetTimelineActive>((event, emit) {
        if (state is! TimeLinesWrapperLoaded) {
          return;
        }

        final current = state as TimeLinesWrapperLoaded;

        final timeline = current.timelines[event.timelineHash];

        if (timeline == null) {
          return;
        }

        if (timeline.active) {
          return;
        }

        final updatedTimelines = Map<int, Timeline>.from(current.timelines);

        timeline.active = true;
        updatedTimelines[event.timelineHash] = timeline;

        emit(
          current.copyWith(
            timelines: updatedTimelines,
          ),
        );
    });

    on<SetTimelineInActive>((event, emit) {
      if (state is! TimeLinesWrapperLoaded){
        return;
      }
        final current = state as TimeLinesWrapperLoaded;

        final timeline = current.timelines[event.timelineHash];

        if (timeline == null) {
          return;
        }

        if (!timeline.active) {
          return;
        }

        final updatedTimelines = Map<int, Timeline>.from(current.timelines);

        timeline.active = false;
        updatedTimelines[event.timelineHash] = timeline;

        emit(
          current.copyWith(
            timelines: updatedTimelines,
          ),
        );

    });


    on<TimelineScroll>((event, emit) {
      if (state is! TimeLinesWrapperLoaded) return;
        
        final current = state as TimeLinesWrapperLoaded;
        
        if (!current.axisScrollController.hasClients) return;
        
        final timelineOffset = event.scrollController.offset;
        final axisOffset = current.axisScrollController.offset;
        
        if (axisOffset != timelineOffset) {
          current.axisScrollController.jumpTo(timelineOffset);
        }
    });

    on<ReorderTimeline>((event, emit) {
      if (state is! TimeLinesWrapperLoaded) return;
      final current = state as TimeLinesWrapperLoaded;
      
      final newOrder = List<int>.from(current.timelineOrder);
      final item = newOrder.removeAt(event.oldIndex);
      newOrder.insert(event.newIndex, item);
      
      emit(current.copyWith(timelineOrder: newOrder));
    });
    add(LoadTimelineEvents());

  }

  Future<void> _loadTimelines(Emitter<TimeLinesWrapperState> emit) async {
    var groups = await _groupRepository.getAll();
    if (groups == null) {
      return;
    }

    // Index users by id once so each event can be hydrated without a per-event
    // repository round-trip.
    final users = await _userRepository.getAll() ?? const <User>[];
    final usersById = {for (final u in users) u.id: u};

    final activeIds = _activeGroups.map((g) => g.id).toSet();
    // Category selection scopes which timelines are shown.
    final bool hasCategoryFilter = activeIds.isNotEmpty;

    Map<int, Timeline> grouppedEvents = {};
    for (Group group in groups) {
      // When categories are selected, ignore every group that isn't selected.
      if (hasCategoryFilter && !activeIds.contains(group.id)) {
        continue;
      }

      final String groupName = group.title;
      final int key = groupName.hashCode;

      // Fetch the events matching the current query and bind the group to them.
      final groupEvents = (await _eventPostRepository.query(
        groupIds: {group.id},
        startDate: _startDate,
        endDate: _endDate,
        search: _searchQuery,
      )).map((event) {
        event.group = group;
        event.user = usersById[event.userId];
        return event;
      }).toList();

      // The timeline always stays in scope. Search / date only narrow the
      // events inside it; an empty result is shown as "no events" rather than
      // removing the timeline.
      if (!grouppedEvents.containsKey(key)) {
        var timeline = Timeline(
          title: groupName,
          color: group.color,
          events: groupEvents,
          active: true,
          timelineWidget: null,
        );

        grouppedEvents[key] = timeline;
      }
    }

    Map<int, ScrollController> timelineScrollers = {};
    // Foreach group create a timeline
    for (final groupEntry in grouppedEvents.entries) {
      final timeline = TimelineColumn(
        listOfEvents: groupEntry.value.events,
        groupColor: groupEntry.value.color,
      );

      grouppedEvents[groupEntry.key]!.timelineWidget = timeline;
      timelineScrollers[groupEntry.key] = ScrollController();
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
}
