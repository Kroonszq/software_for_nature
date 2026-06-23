import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:software_for_nature/data/data_sources/interfaces/attachment_storage.dart';
import 'package:software_for_nature/data/models/category.dart';
import 'package:software_for_nature/data/models/event_attachment.dart';
import 'package:software_for_nature/data/models/event_chart.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/tag.dart';
import 'package:software_for_nature/logic/services/interfaces/category_service_interface.dart';
import 'package:software_for_nature/logic/services/interfaces/event_service_interface.dart';
import 'package:software_for_nature/logic/services/interfaces/user_service_interface.dart';

part 'event_form_bloc_event.dart';
part 'event_form_bloc_state.dart';

class EventFormBloc extends Bloc<EventFormBlocEvent, EventFormBlocState> {
  final AttachmentStorageInterface _attachmentStorage;
  final CategoryServiceInterface _categoryService;
  final EventServiceInterface _eventService;
  final UserServiceInterface _userService;

  /// When set, the form edits this existing event instead of creating a new one.
  final EventPost? _initialEvent;

  /// Whether the form is editing an existing event rather than creating one.
  bool get isEditing => _initialEvent != null;

  EventFormBloc({required this._attachmentStorage, required this._categoryService, required this._eventService, required this._userService, EventPost? initialEvent,}): _initialEvent = initialEvent, super(_initialStateFor(initialEvent)) {
    on<CategoriesRequested>(_onCategoriesRequested);
    on<TagsRequested>(_onTagsRequested);
    on<TagSelected>((e, emit) => emit(
          state.copyWith(selectedTags: [...state.selectedTags, e.tag]),
        ));
    on<TagDeselected>((e, emit) => emit(
          state.copyWith(
            selectedTags: state.selectedTags.where((t) => t != e.tag).toList(),
          ),
        ));
    on<TagCreated>(_onTagCreated);
    on<TitleChanged>((e, emit) => emit(state.copyWith(title: e.title)));
    on<DescriptionChanged>((e, emit) => emit(state.copyWith(description: e.description)));
    on<CategorySelected>((e, emit) => emit(state.copyWith(categoryId: e.categoryId)));
    on<TimeModeChanged>((e, emit) => emit(state.copyWith(mode: e.mode)));
    on<StartChanged>((e, emit) => emit(state.copyWith(start: e.start)));
    on<EndChanged>((e, emit) => emit(state.copyWith(end: e.end)));
    on<TimestampChanged>((e, emit) => emit(state.copyWith(timestamp: e.timestamp)));
    on<AttachmentsAdded>((e, emit) => emit(state.copyWith(attachments: [...state.attachments, ...e.attachments])));
    on<AttachmentRemoved>((e, emit) => emit(state.copyWith(attachments: state.attachments.where((a) => a != e.attachment).toList())));
    on<ChartAdded>((e, emit) => emit(state.copyWith(charts: [...state.charts, e.chart])));
    on<ChartRemoved>((e, emit) => emit(state.copyWith(charts: state.charts.where((c) => c != e.chart).toList())));
    on<FormSubmitted>(_onSubmitted);

    add(CategoriesRequested());
    add(TagsRequested());
  }

  /// Builds the form's starting state, pre-filled from [event] when editing.
  static EventFormBlocState _initialStateFor(EventPost? event) {
    if (event == null) {
      return const EventFormBlocState();
    }

    return EventFormBlocState(
      title: event.title,
      description: event.description,
      categoryId: event.categoryId,
      availableTags: const [],
      selectedTags: event.tags,
      mode: event.isMoment ? EventTimeMode.timestamp : EventTimeMode.range,
      start: event.startDuration,
      end: event.endDuration,
      timestamp: event.timestamp,
      attachments: event.attachments,
      charts: event.charts,
    );
  }

  Future<void> _onCategoriesRequested(CategoriesRequested event, Emitter<EventFormBlocState> emit) async {
    final categories = await _categoryService.getAllCategories();
    emit(state.copyWith(categories: categories));
  }

  /// Adds a freshly created tag to the selection. A tag is considered to
  /// already exist when another tag shares its label (case-insensitive); in
  /// that case the existing tag is reused so we never store duplicates.
  void _onTagCreated(TagCreated event, Emitter<EventFormBlocState> emit) {
    final label = event.tag.label.trim();
    if (label.isEmpty) {
      return;
    }

    bool sameLabel(Tag tag) => tag.label.toLowerCase() == label.toLowerCase();

    // Already selected: nothing to do.
    if (state.selectedTags.any(sameLabel)) {
      return;
    }

    // Reuse an existing available tag with the same label, otherwise use the
    // new one and remember it as available too.
    final existing = state.availableTags.where(sameLabel).toList();
    final tag = existing.isNotEmpty
        ? existing.first
        : Tag(label: label, color: event.tag.color);

    final availableTags = existing.isNotEmpty
        ? state.availableTags
        : [...state.availableTags, tag];

    emit(state.copyWith(
      availableTags: availableTags,
      selectedTags: [...state.selectedTags, tag],
    ));
  }

  Future<void> _onTagsRequested(TagsRequested event, Emitter<EventFormBlocState> emit) async {
    final events = await _eventService.getAllEvents();
    final Map<String, Tag> distinctTags = {};
    for (final e in events) {
      for (final tag in e.tags) {
        distinctTags.putIfAbsent(tag.label, () => tag);
      }
    }
    emit(state.copyWith(availableTags: distinctTags.values.toList()));
  }

  Future<void> _onSubmitted(FormSubmitted event, Emitter<EventFormBlocState> emit) async {
    if (state.categoryId == null) {
      emit(state.copyWith(status: EventFormStatus.failure, error: 'Pick a category'));
      return;
    }

    DateTime start;
    DateTime end;
    DateTime? timestamp;

    if (state.mode == EventTimeMode.range) {
      if (state.start == null || state.end == null) {
        emit(state.copyWith(status: EventFormStatus.failure, error: 'Pick a start and end time'));
        return;
      }
      if (!state.end!.isAfter(state.start!)) {
        emit(state.copyWith(status: EventFormStatus.failure, error: 'End must be after start'));
        return;
      }
      start = state.start!;
      end = state.end!;
      timestamp = null;
    } else {
      if (state.timestamp == null) {
        emit(state.copyWith(status: EventFormStatus.failure, error: 'Pick a date and time'));
        return;
      }

      start = state.timestamp!;
      end = state.timestamp!;
      timestamp = state.timestamp!;
    }

    emit(state.copyWith(status: EventFormStatus.submitting));
    try {

      // Editing an existing event: keep its identity (id, author, created date)
      // and only update the edited fields.
      if (_initialEvent != null) {
        final attachments = await _persistEditedAttachments(_initialEvent);

        final updated = EventPost(
          id: _initialEvent.id,
          title: state.title,
          description: state.description,
          createdAt: _initialEvent.createdAt,
          timestamp: timestamp,
          startDuration: start,
          endDuration: end,
          categoryId: state.categoryId!,
          userId: _initialEvent.userId,
          coordinates: _initialEvent.coordinates,
          attachments: attachments,
          charts: state.charts,
          tags: state.selectedTags,
        )
          ..category = _initialEvent.category
          ..user = _initialEvent.user;

        await _eventService.updateEvent(updated);
        emit(state.copyWith(status: EventFormStatus.success));
        return;
      }

      final users = await _userService.getAllUsers();
      if (users.isEmpty) {
        emit(state.copyWith(status: EventFormStatus.failure, error: 'No user available'));
        return;
      }
      final userId = users.first.id;

      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final attachments = await _attachmentStorage.persistAll(state.attachments, id);

      final eventPost = EventPost(
        id: id,
        title: state.title,
        description: state.description,
        createdAt: DateTime.now(),
        timestamp: timestamp,
        startDuration: start,
        endDuration: end,
        categoryId: state.categoryId!,
        userId: userId,
        attachments: attachments,
        charts: state.charts,
        tags: state.selectedTags,
      );

      await _eventService.createEvent(eventPost);
      emit(state.copyWith(status: EventFormStatus.success));
    } catch (e) {
      emit(state.copyWith(status: EventFormStatus.failure, error: e.toString()));
    }
  }

  /// Persists only the attachments newly added during an edit; existing ones are
  /// already on disk and must not be re-copied (their path is relative, not a
  /// real source file).
  Future<List<EventAttachment>> _persistEditedAttachments(EventPost original) async {
    final kept = <EventAttachment>[];
    final added = <EventAttachment>[];
    for (final attachment in state.attachments) {
      if (original.attachments.contains(attachment)) {
        kept.add(attachment);
      } else {
        added.add(attachment);
      }
    }

    final persisted = await _attachmentStorage.persistAll(added, original.id);
    return [...kept, ...persisted];
  }
}
