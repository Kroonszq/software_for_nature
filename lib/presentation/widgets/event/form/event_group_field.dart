import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/logic/bloc/event_form_bloc/event_form_bloc.dart';

class EventGroupField extends StatelessWidget {
  const EventGroupField({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventFormBloc, EventFormBlocState>(
      buildWhen: (prev, curr) => prev.groups != curr.groups || prev.groupId != curr.groupId,
      builder: (context, state) {

        // Build the list of dropdownmenuitems based of the groups
        List<DropdownMenuItem<String>> dropDownMenuItems = state.groups.map((g) => 
          DropdownMenuItem(
            value: g.id,
            child: Text(g.title),
            )
          ).toList();

        return DropdownButtonFormField<String>(
          initialValue: state.groupId,
          decoration: const InputDecoration(labelText: 'Group'),
          validator: (v) {
            if(v == null){
              return 'Please select a group';
            } 
  
            return null;
          },
          items: dropDownMenuItems,
          onChanged: (v) {
            if (v != null){ 
              context.read<EventFormBloc>().add(GroupChanged(v));
            }
          },
        );
      },
    );
  }
}
