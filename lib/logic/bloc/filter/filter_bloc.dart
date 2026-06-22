import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:software_for_nature/data/models/group.dart';
import 'package:software_for_nature/data/models/tag.dart';
import 'package:software_for_nature/data/repositories/interfaces/event_post_repository_interface.dart';
import 'package:software_for_nature/data/repositories/interfaces/group_repository_interface.dart';

part 'filter_event.dart';
part 'filter_state.dart';

class FilterBloc extends Bloc<FilterEvent, FilterState> {
  final GroupRepositoryInterface _groupRepositoryInterface;
  final EventPostRepositoryInterface _eventPostRepositoryInterface;


  FilterBloc({
    required this._groupRepositoryInterface,
    required this._eventPostRepositoryInterface,
  }) : super(FilterInitial()) {

    on<FilterStarted>((event, emit) async {
      final groups = await _groupRepositoryInterface.getAll();

      final events = await _eventPostRepositoryInterface.getAll() ?? const [];
      final Map<String, Tag> distinctTags = {};
      for (final e in events) {
        for (final t in e.tags) {
          distinctTags.putIfAbsent(t.label, () => t);
        }
      }
      final tags = distinctTags.values.toList();

      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final endOfToday = DateTime(now.year, now.month, now.day, 23, 59);

      // Start with every category/group and every tag selected by default
      emit(FilterLoaded(
        groups: groups,
        activeGroups: groups == null ? null : List<Group>.of(groups),
        tags: tags,
        activeTags: List<Tag>.of(tags),
        startDate: startOfToday,
        endDate: endOfToday,
      ));
    });

    on<CategoryChanged>((event, emit) {
      final current = state;
      if (current is FilterLoaded) {
        final active = List<Group>.of(current.activeGroups ?? const []);

        if (active.any((g) => g.id == event.group.id)) {
          active.removeWhere((g) => g.id == event.group.id);
        } else {
          active.add(event.group);
        }

        emit(current.copyWith(activeGroups: active));
      }
    });

    on<TagChanged>((event, emit) {
      final current = state;
      if (current is FilterLoaded) {
        final active = List<Tag>.of(current.activeTags ?? const []);

        if (active.any((t) => t.label == event.tag.label)) {
          active.removeWhere((t) => t.label == event.tag.label);
        } else {
          active.add(event.tag);
        }

        emit(current.copyWith(activeTags: active));
      }
    });

    on<DateRangeChanged>((event, emit) {
      final current = state;
      if (current is FilterLoaded) {
        emit(FilterLoaded(
          groups: current.groups,
          activeGroups: current.activeGroups,
          tags: current.tags,
          activeTags: current.activeTags,
          startDate: event.startDate,
          endDate: event.endDate,
          searchQuery: current.searchQuery,
        ));
      }
    });

    on<SearchChanged>((event, emit) {
      final current = state;
      if (current is FilterLoaded) {
        emit(FilterLoaded(
          groups: current.groups,
          activeGroups: current.activeGroups,
          tags: current.tags,
          activeTags: current.activeTags,
          startDate: current.startDate,
          endDate: current.endDate,
          searchQuery: event.query,
        ));
      }
    });
  }
}
