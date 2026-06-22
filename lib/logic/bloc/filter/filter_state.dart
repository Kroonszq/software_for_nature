part of 'filter_bloc.dart';

@immutable
sealed class FilterState {}

final class FilterInitial extends FilterState {


}


final class FilterLoaded extends FilterState  {
  final List<Group>? groups;
  final List<Group>? activeGroups;
  final List<Tag>? tags;
  final List<Tag>? activeTags;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;

  FilterLoaded({
    required this.groups,
    this.activeGroups,
    this.tags,
    this.activeTags,
    this.startDate,
    this.endDate,
    this.searchQuery,
  });

  FilterLoaded copyWith({
    List<Group>? groups,
    List<Group>? activeGroups,
    List<Tag>? tags,
    List<Tag>? activeTags,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) {
    return FilterLoaded(
      groups: groups ?? this.groups,
      activeGroups: activeGroups ?? this.activeGroups,
      tags: tags ?? this.tags,
      activeTags: activeTags ?? this.activeTags,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

