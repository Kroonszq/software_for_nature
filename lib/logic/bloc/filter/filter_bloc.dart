import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:software_for_nature/data/models/category.dart';
import 'package:software_for_nature/data/models/tag.dart';
import 'package:software_for_nature/logic/services/interfaces/category_service_interface.dart';
import 'package:software_for_nature/logic/services/interfaces/event_service_interface.dart';

part 'filter_event.dart';
part 'filter_state.dart';

class FilterBloc extends Bloc<FilterEvent, FilterState> {
  final CategoryServiceInterface _categoryService;
  final EventServiceInterface _eventService;


  FilterBloc({required this._categoryService, required this._eventService}): super(FilterInitial()) {

    on<FilterStarted>((event, emit) async {
      final categories = await _categoryService.getAllCategories();

      final events = await _eventService.getAllEvents();
      final Map<String, Tag> distinctTags = {};
      for (final e in events) {
        for (final t in e.tags) {
          distinctTags.putIfAbsent(t.label, () => t);
        }
      }
      final tags = distinctTags.values.toList();

      // Start with every category and every tag selected, and no date range so
      // the timeline shows everything until the user picks one.
      emit(FilterLoaded(
        categories: categories,
        activeCategories: List<Category>.of(categories),
        tags: tags,
        activeTags: List<Tag>.of(tags),
      ));
    });

    on<CategoryChanged>((event, emit) {
      final current = state;
      if (current is FilterLoaded) {
        final active = List<Category>.of(current.activeCategories ?? const []);

        if (active.any((c) => c.id == event.category.id)) {
          active.removeWhere((c) => c.id == event.category.id);
        } else {
          active.add(event.category);
        }

        emit(current.copyWith(activeCategories: active));
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
          categories: current.categories,
          activeCategories: current.activeCategories,
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
          categories: current.categories,
          activeCategories: current.activeCategories,
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
