import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/logic/bloc/event_form_bloc/event_form_bloc.dart';

class EventTitleField extends StatelessWidget {
  const EventTitleField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Title'),
      validator: (v) {
        if (v == null || v.isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
      onChanged: (v) => context.read<EventFormBloc>().add(TitleChanged(v)),
    );
  }
}
