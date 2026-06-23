import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/logic/bloc/event_form_bloc/event_form_bloc.dart';
import 'package:software_for_nature/presentation/widgets/event/form/event_attachments_field.dart';
import 'package:software_for_nature/presentation/widgets/event/form/event_category_field.dart';
import 'package:software_for_nature/presentation/widgets/event/form/event_date_time_field.dart';
import 'package:software_for_nature/presentation/widgets/event/form/event_description_field.dart';
import 'package:software_for_nature/presentation/widgets/event/form/event_submit_button.dart';
import 'package:software_for_nature/presentation/widgets/event/form/event_tags_field.dart';
import 'package:software_for_nature/presentation/widgets/event/form/event_time_mode_field.dart';
import 'package:software_for_nature/presentation/widgets/event/form/event_title_field.dart';

class EventForm extends StatelessWidget {
  const EventForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventFormBloc, EventFormBlocState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == EventFormStatus.success) {
          // Return true so the opener knows a save happened and can refresh.
          Navigator.of(context).pop(true);
        } else if (state.status == EventFormStatus.failure && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            EventTitleField(),
            EventDescriptionField(),
            SizedBox(height: 16),
            EventCategoryField(),
            SizedBox(height: 16),
            EventTagsField(),
            SizedBox(height: 16),
            EventTimeModeField(),
            SizedBox(height: 16),
            EventDateTimeField(),
            SizedBox(height: 16),
            EventAttachmentsField(),
            EventSubmitButton(),
          ],
        ),
      ),
    );
  }
}
