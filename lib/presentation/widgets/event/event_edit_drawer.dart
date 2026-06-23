import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/data_sources/interfaces/attachment_storage.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/logic/bloc/event_form_bloc/event_form_bloc.dart';
import 'package:software_for_nature/logic/services/interfaces/category_service_interface.dart';
import 'package:software_for_nature/logic/services/interfaces/event_service_interface.dart';
import 'package:software_for_nature/logic/services/interfaces/user_service_interface.dart';
import 'package:software_for_nature/presentation/widgets/event/event_form.dart';

/// Opens the event editor as a panel that slides in from the right, pre-filled
/// with [event]. The editor reuses [EventForm]; on success the form pops this
/// route, closing the panel.
void openEventEditor(BuildContext context, EventPost event) {
  final categoryService = context.read<CategoryServiceInterface>();
  final eventService = context.read<EventServiceInterface>();
  final userService = context.read<UserServiceInterface>();
  final attachmentStorage = context.read<AttachmentStorageInterface>();

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Edit event',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: BlocProvider(
          create: (_) => EventFormBloc(
            categoryService: categoryService,
            eventService: eventService,
            userService: userService,
            attachmentStorage: attachmentStorage,
            initialEvent: event,
          ),
          child: const _EventEditPanel(),
        ),
      );
    },
    transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}

class _EventEditPanel extends StatelessWidget {
  const _EventEditPanel();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double panelWidth = screenWidth < 600 ? screenWidth * 0.9 : 480;

    return SizedBox(
      width: panelWidth,
      height: double.infinity,
      child: Material(
        elevation: 16,
        color: Theme.of(context).canvasColor,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                child: Row(
                  children: [
                    const Text(
                      'Edit event',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              const Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: EventForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
