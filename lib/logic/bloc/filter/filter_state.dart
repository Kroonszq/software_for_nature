part of 'filter_bloc.dart';

@immutable
sealed class FilterState {}

final class FilterInitial extends FilterState {


}


final class FilterLoaded extends FilterState  {
  final List<Category>? categories;
  final List<Category>? activeCategories;
  final List<Tag>? tags;
  final List<Tag>? activeTags;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;

  FilterLoaded({
    required this.categories,
    this.activeCategories,
    this.tags,
    this.activeTags,
    this.startDate,
    this.endDate,
    this.searchQuery,
  });

  FilterLoaded copyWith({
    List<Category>? categories,
    List<Category>? activeCategories,
    List<Tag>? tags,
    List<Tag>? activeTags,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) {
    return FilterLoaded(
      categories: categories ?? this.categories,
      activeCategories: activeCategories ?? this.activeCategories,
      tags: tags ?? this.tags,
      activeTags: activeTags ?? this.activeTags,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
