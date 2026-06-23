part of 'event_form_bloc.dart';

enum EventFormStatus { editing, submitting, success, failure }

/// Whether the event spans a date range (start + end) or happens at a single
/// point in time (timestamp).
enum EventTimeMode { range, timestamp }

@immutable
final class EventFormBlocState {
  final String title;
  final String description;
  final List<Category> categories;
  final String? categoryId;
  final List<Tag> tags;
  final EventTimeMode mode;
  final DateTime? start;
  final DateTime? end;
  final DateTime? timestamp;
  final List<EventAttachment> attachments;
  final EventFormStatus status;
  final String? error;

  const EventFormBlocState({
    this.title = '',
    this.description = '',
    this.tags = const [],
    this.categories = const [],
    this.categoryId,
    this.mode = EventTimeMode.range,
    this.start,
    this.end,
    this.timestamp,
    this.attachments = const [],
    this.status = EventFormStatus.editing,
    this.error,
  });

  EventFormBlocState copyWith({
    String? title,
    String? description,
    List<Category>? categories,
    List<Tag>? tags,
    String? categoryId,
    EventTimeMode? mode,
    DateTime? start,
    DateTime? end,
    DateTime? timestamp,
    List<EventAttachment>? attachments,
    EventFormStatus? status,
    String? error,
  }) {
    return EventFormBlocState(
      title: title ?? this.title,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      categoryId: categoryId ?? this.categoryId,
      mode: mode ?? this.mode,
      start: start ?? this.start,
      end: end ?? this.end,
      timestamp: timestamp ?? this.timestamp,
      attachments: attachments ?? this.attachments,
      status: status ?? this.status,
      error: error,
    );
  }
}
