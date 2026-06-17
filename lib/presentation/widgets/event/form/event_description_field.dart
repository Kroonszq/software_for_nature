import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/logic/bloc/event_form_bloc/event_form_bloc.dart';

class EventDescriptionField extends StatelessWidget {
  const EventDescriptionField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Description',
        alignLabelWithHint: true,
      ),
      minLines: 4,
      maxLines: 8,
      keyboardType: TextInputType.multiline,
      onChanged: (v) => context.read<EventFormBloc>().add(DescriptionChanged(v)),
    );
  }
}
