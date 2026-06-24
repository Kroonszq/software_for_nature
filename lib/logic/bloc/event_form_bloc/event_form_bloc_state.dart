part of 'event_form_bloc.dart';

enum EventFormStatus { editing, submitting, success, failure }


enum EventTimeMode { range, timestamp }

@immutable
final class EventFormBlocState {
  final String title;
  final String description;
  final List<Category> categories;
  final String? categoryId;
  final List<Tag> availableTags;
  final List<Tag> selectedTags;
  final EventTimeMode mode;
  final DateTime? start;
  final DateTime? end;
  final DateTime? timestamp;
  final List<EventAttachment> attachments;
  final List<EventChart> charts;
  final EventFormStatus status;
  final String? error;

  const EventFormBlocState({
    this.title = '',
    this.description = '',
    this.availableTags = const [],
    this.selectedTags = const [],
    this.categories = const [],
    this.categoryId,
    this.mode = EventTimeMode.range,
    this.start,
    this.end,
    this.timestamp,
    this.attachments = const [],
    this.charts = const [],
    this.status = EventFormStatus.editing,
    this.error,
  });

  EventFormBlocState copyWith({
    String? title,
    String? description,
    List<Category>? categories,
    List<Tag>? availableTags,
    List<Tag>? selectedTags,
    String? categoryId,
    EventTimeMode? mode,
    DateTime? start,
    DateTime? end,
    DateTime? timestamp,
    List<EventAttachment>? attachments,
    List<EventChart>? charts,
    EventFormStatus? status,
    String? error,
  }) {
    return EventFormBlocState(
      title: title ?? this.title,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      availableTags: availableTags ?? this.availableTags,
      selectedTags: selectedTags ?? this.selectedTags,
      categoryId: categoryId ?? this.categoryId,
      mode: mode ?? this.mode,
      start: start ?? this.start,
      end: end ?? this.end,
      timestamp: timestamp ?? this.timestamp,
      attachments: attachments ?? this.attachments,
      charts: charts ?? this.charts,
      status: status ?? this.status,
      error: error,
    );
  }
}
