import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:software_for_nature/data/models/group.dart';
import 'package:software_for_nature/data/repositories/interfaces/group_repository_interface.dart';

part 'filter_event.dart';
part 'filter_state.dart';

class FilterBloc extends Bloc<FilterEvent, FilterState> {
  final GroupRepositoryInterface _groupRepositoryInterface;


  FilterBloc({required this._groupRepositoryInterface}) : super(FilterInitial()) {

    on<FilterStarted>((event, emit) async {
      var groups = await _groupRepositoryInterface.getAll();

      emit(FilterLoaded(groups: groups));
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

        emit(current.copyWith(null, active));
      }
    });

    on<DateRangeChanged>((event, emit) {
      final current = state;
      if (current is FilterLoaded) {
        emit(FilterLoaded(
          groups: current.groups,
          activeGroups: current.activeGroups,
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
          startDate: current.startDate,
          endDate: current.endDate,
          searchQuery: event.query,
        ));
      }
    });
  }
}
