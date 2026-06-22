part of 'filter_bloc.dart';

@immutable
sealed class FilterEvent {}


final class FilterStarted extends FilterEvent {}


final class CategoryChanged extends FilterEvent{
  final Group group;

  CategoryChanged(this.group);
}


/// Toggles a tag in/out of the active tag selection
final class TagChanged extends FilterEvent {
  final Tag tag;

  TagChanged(this.tag);
}


final class DateRangeChanged extends FilterEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  DateRangeChanged(this.startDate, this.endDate);
}


final class SearchChanged extends FilterEvent {
  final String query;

  SearchChanged(this.query);
}

