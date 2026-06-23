import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/data_sources/interfaces/attachment_storage.dart';
import 'package:software_for_nature/logic/bloc/event_form_bloc/event_form_bloc.dart';
import 'package:software_for_nature/logic/services/interfaces/category_service_interface.dart';
import 'package:software_for_nature/logic/services/interfaces/event_service_interface.dart';
import 'package:software_for_nature/logic/services/interfaces/user_service_interface.dart';
import 'package:software_for_nature/presentation/widgets/event/event_form.dart';
import 'package:software_for_nature/presentation/widgets/event/event_refresh.dart';

class EventCreateDrawer extends StatelessWidget {
  const EventCreateDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    // Capture the refresh from the drawer's own (page-scoped) context now, while
    // it is guaranteed to be mounted under the page providers. The form closes
    // the drawer on success, which can deactivate the listener's context before
    // a context-based lookup would resolve, so we hold the bloc refs directly.
    final refresh = captureEventRefresh(context);

    return Drawer(
      width: width < 600 ? width * 0.9 : 480,
      child: BlocProvider(
        create: (_) => EventFormBloc(
          categoryService: context.read<CategoryServiceInterface>(),
          eventService: context.read<EventServiceInterface>(),
          userService: context.read<UserServiceInterface>(),
          attachmentStorage: context.read<AttachmentStorageInterface>(),
        ),
        // Reload the page's event data once a create succeeds so the new event
        // appears on the timeline/map immediately.
        child: BlocListener<EventFormBloc, EventFormBlocState>(
          listenWhen: (prev, curr) =>
              prev.status != curr.status &&
              curr.status == EventFormStatus.success,
          listener: (context, state) => refresh(),
          child: const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: EventForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
