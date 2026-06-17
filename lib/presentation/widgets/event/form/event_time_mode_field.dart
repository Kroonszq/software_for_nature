import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/logic/bloc/event_form_bloc/event_form_bloc.dart';

class EventTimeModeField extends StatelessWidget {
  const EventTimeModeField({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventFormBloc, EventFormBlocState>(
      buildWhen: (prev, curr) => prev.mode != curr.mode,
      builder: (context, state) {
        return SegmentedButton<EventTimeMode>(
          segments: const [
            ButtonSegment(
              value: EventTimeMode.range,
              label: Text('Range'),
              icon: Icon(Icons.date_range),
            ),
            ButtonSegment(
              value: EventTimeMode.timestamp,
              label: Text('Moment'),
              icon: Icon(Icons.schedule),
            ),
          ],
          selected: {state.mode},
          onSelectionChanged: (sel) =>
              context.read<EventFormBloc>().add(TimeModeChanged(sel.first)),
        );
      },
    );
  }
}
