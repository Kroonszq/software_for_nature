import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:software_for_nature/data/data_sources/interfaces/attachment_storage.dart';
import 'package:software_for_nature/data/models/category.dart';
import 'package:software_for_nature/data/models/event_attachment.dart';
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

  EventFormBloc({required this._attachmentStorage, required this._categoryService, required this._eventService, required this._userService,}): super(const EventFormBlocState()) {
    on<CategoriesRequested>(_onCategoriesRequested);
    on<TitleChanged>((e, emit) => emit(state.copyWith(title: e.title)));
    on<DescriptionChanged>((e, emit) => emit(state.copyWith(description: e.description)));
    on<CategorySelected>((e, emit) => emit(state.copyWith(categoryId: e.categoryId)));
    on<TimeModeChanged>((e, emit) => emit(state.copyWith(mode: e.mode)));
    on<StartChanged>((e, emit) => emit(state.copyWith(start: e.start)));
    on<EndChanged>((e, emit) => emit(state.copyWith(end: e.end)));
    on<TimestampChanged>((e, emit) => emit(state.copyWith(timestamp: e.timestamp)));
    on<AttachmentsAdded>((e, emit) => emit(state.copyWith(attachments: [...state.attachments, ...e.attachments])));
    on<AttachmentRemoved>((e, emit) => emit(state.copyWith(attachments: state.attachments.where((a) => a != e.attachment).toList())));
    on<FormSubmitted>(_onSubmitted);

    add(CategoriesRequested());
  }

  Future<void> _onCategoriesRequested(CategoriesRequested event, Emitter<EventFormBlocState> emit) async {
    final categories = await _categoryService.getAllCategories();
    emit(state.copyWith(categories: categories));
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
      );

      await _eventService.createEvent(eventPost);
      emit(state.copyWith(status: EventFormStatus.success));
    } catch (e) {
      emit(state.copyWith(status: EventFormStatus.failure, error: e.toString()));
    }
  }
}
