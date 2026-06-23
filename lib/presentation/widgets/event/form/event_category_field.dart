import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/logic/bloc/event_form_bloc/event_form_bloc.dart';

class EventCategoryField extends StatelessWidget {
  const EventCategoryField({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventFormBloc, EventFormBlocState>(
      buildWhen: (prev, curr) =>
          prev.categories != curr.categories || prev.categoryId != curr.categoryId,
      builder: (context, state) {
        // Build the list of dropdownmenuitems based of the categories
        List<DropdownMenuItem<String>> dropDownMenuItems = state.categories
            .map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(c.name),
                ))
            .toList();

        return DropdownButtonFormField<String>(
          initialValue: state.categoryId,
          decoration: const InputDecoration(labelText: 'Category'),
          validator: (v) {
            if (v == null) {
              return 'Please select a category';
            }

            return null;
          },
          items: dropDownMenuItems,
          onChanged: (v) {
            if (v != null) {
              context.read<EventFormBloc>().add(CategorySelected(v));
            }
          },
        );
      },
    );
  }
}
