import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/data_sources/interfaces/attachment_storage.dart';
import 'package:software_for_nature/data/repositories/interfaces/event_post_repository_interface.dart';
import 'package:software_for_nature/data/repositories/interfaces/group_repository_interface.dart';
import 'package:software_for_nature/data/repositories/interfaces/user_repository_interface.dart';
import 'package:software_for_nature/logic/bloc/event_form_bloc/event_form_bloc.dart';
import 'package:software_for_nature/presentation/widgets/event/event_form.dart';

class EventCreateDrawer extends StatelessWidget {
  const EventCreateDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Drawer(
      width: width < 600 ? width * 0.9 : 480,
      child: BlocProvider(
        create: (_) => EventFormBloc(
          groupRepository: context.read<GroupRepositoryInterface>(),
          eventRepository: context.read<EventPostRepositoryInterface>(),
          userRepository: context.read<UserRepositoryInterface>(),
          attachmentStorage: context.read<AttachmentStorageInterface>(),
        ),
        child: const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: EventForm(),
            ),
          ),
        ),
      ),
    );
  }
}
