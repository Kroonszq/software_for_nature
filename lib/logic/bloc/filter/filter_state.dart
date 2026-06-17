part of 'filter_bloc.dart';

@immutable
sealed class FilterState {}

final class FilterInitial extends FilterState {


}


final class FilterLoaded extends FilterState  {
  final List<Group>? groups;
  final List<Group>? activeGroups;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;

  FilterLoaded({
    required this.groups,
    this.activeGroups,
    this.startDate,
    this.endDate,
    this.searchQuery,
  });

  FilterLoaded copyWith(
    List<Group>? groups,
    List<Group>? activeGroups
  )
  {
    return FilterLoaded(
      groups: groups ?? this.groups,
      activeGroups: activeGroups ?? this.activeGroups,
      startDate: startDate,
      endDate: endDate,
      searchQuery: searchQuery
    );
  }
}

