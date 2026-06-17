import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:software_for_nature/data/data_sources/interfaces/attachment_storage.dart';
import 'package:software_for_nature/data/models/event_attachment.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/group.dart';
import 'package:software_for_nature/data/repositories/interfaces/event_post_repository_interface.dart';
import 'package:software_for_nature/data/repositories/interfaces/group_repository_interface.dart';
import 'package:software_for_nature/data/repositories/interfaces/user_repository_interface.dart';

part 'event_form_bloc_event.dart';
part 'event_form_bloc_state.dart';

class EventFormBloc extends Bloc<EventFormBlocEvent, EventFormBlocState> {
  final GroupRepositoryInterface _groupRepository;
  final EventPostRepositoryInterface _eventRepository;
  final UserRepositoryInterface _userRepository;
  final AttachmentStorageInterface _attachmentStorage;

  EventFormBloc({required this._groupRepository, required this._eventRepository, required this._userRepository, required this._attachmentStorage,}) :super(const EventFormBlocState()) {
    on<GroupsRequested>(_onGroupsRequested);
    on<TitleChanged>((e, emit) => emit(state.copyWith(title: e.title)));
    on<DescriptionChanged>((e, emit) => emit(state.copyWith(description: e.description)));
    on<GroupChanged>((e, emit) => emit(state.copyWith(groupId: e.groupId)));
    on<TimeModeChanged>((e, emit) => emit(state.copyWith(mode: e.mode)));
    on<StartChanged>((e, emit) => emit(state.copyWith(start: e.start)));
    on<EndChanged>((e, emit) => emit(state.copyWith(end: e.end)));
    on<TimestampChanged>((e, emit) => emit(state.copyWith(timestamp: e.timestamp)));
    on<AttachmentsAdded>((e, emit) => emit(state.copyWith(attachments: [...state.attachments, ...e.attachments])));
    on<AttachmentRemoved>((e, emit) => emit(state.copyWith(attachments: state.attachments.where((a) => a != e.attachment).toList())));
    on<FormSubmitted>(_onSubmitted);

    add(GroupsRequested());
  }

  Future<void> _onGroupsRequested(
      GroupsRequested event, Emitter<EventFormBlocState> emit) async {
    final groups = await _groupRepository.getAll() ?? const [];
    emit(state.copyWith(groups: groups));
  }

  Future<void> _onSubmitted(FormSubmitted event, Emitter<EventFormBlocState> emit) async {
    if (state.groupId == null) {
      emit(state.copyWith(status: EventFormStatus.failure, error: 'Pick a group'));
      return;
    }

    DateTime start;
    DateTime end;
    DateTime timestamp;

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
      timestamp = state.start!;
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
      // Resolve the owning user. Until real auth exists, the first user
      // (the seeded test user, id "1") is treated as the current user.
      final users = await _userRepository.getAll() ?? const [];
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
        timestamp: timestamp,
        startDuration: start,
        endDuration: end,
        groupId: state.groupId!,
        userId: userId,
        attachments: attachments,
      );

      await _eventRepository.create(eventPost);
      emit(state.copyWith(status: EventFormStatus.success));
    } catch (e) {
      emit(state.copyWith(status: EventFormStatus.failure, error: e.toString()));
    }
  }
}
