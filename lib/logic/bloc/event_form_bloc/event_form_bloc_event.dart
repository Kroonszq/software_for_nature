part of 'event_form_bloc.dart';

@immutable
sealed class EventFormBlocEvent {}

final class CategoriesRequested extends EventFormBlocEvent {}

final class TagsRequested extends EventFormBlocEvent {}

final class TagSelected extends EventFormBlocEvent {
  final Tag tag;
  TagSelected(this.tag);
}

final class TagDeselected extends EventFormBlocEvent {
  final Tag tag;
  TagDeselected(this.tag);
}

final class TitleChanged extends EventFormBlocEvent {
  final String title;
  TitleChanged(this.title);
}

final class DescriptionChanged extends EventFormBlocEvent {
  final String description;
  DescriptionChanged(this.description);
}

final class CategorySelected extends EventFormBlocEvent {
  final String categoryId;
  CategorySelected(this.categoryId);
}

final class TimeModeChanged extends EventFormBlocEvent {
  final EventTimeMode mode;
  TimeModeChanged(this.mode);
}

final class StartChanged extends EventFormBlocEvent {
  final DateTime start;
  StartChanged(this.start);
}

final class EndChanged extends EventFormBlocEvent {
  final DateTime end;
  EndChanged(this.end);
}

final class TimestampChanged extends EventFormBlocEvent {
  final DateTime timestamp;
  TimestampChanged(this.timestamp);
}

final class AttachmentsAdded extends EventFormBlocEvent {
  final List<EventAttachment> attachments;
  AttachmentsAdded(this.attachments);
}

final class AttachmentRemoved extends EventFormBlocEvent {
  final EventAttachment attachment;
  AttachmentRemoved(this.attachment);
}

final class FormSubmitted extends EventFormBlocEvent {}
