import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/logic/bloc/event_form_bloc/event_form_bloc.dart';

class EventDateTimeField extends StatelessWidget {
  const EventDateTimeField({super.key});

  String _fmt(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }

  Future<DateTime?> _pickDateTime(BuildContext context, DateTime? initial) async {
    final now = DateTime.now();
    final base = initial ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !context.mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventFormBloc, EventFormBlocState>(
      buildWhen: (prev, curr) =>
          prev.mode != curr.mode ||
          prev.start != curr.start ||
          prev.end != curr.end ||
          prev.timestamp != curr.timestamp,
      builder: (context, state) {
        final bloc = context.read<EventFormBloc>();
        if (state.mode == EventTimeMode.range) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DateTimeButton(
                label: 'Start',
                value: state.start,
                format: _fmt,
                onTap: () async {
                  final picked = await _pickDateTime(context, state.start);
                  if (picked != null) bloc.add(StartChanged(picked));
                },
              ),
              const SizedBox(height: 8),
              _DateTimeButton(
                label: 'End',
                value: state.end,
                format: _fmt,
                onTap: () async {
                  final picked = await _pickDateTime(context, state.end);
                  if (picked != null) bloc.add(EndChanged(picked));
                },
              ),
            ],
          );
        }
        return _DateTimeButton(
          label: 'Date & time',
          value: state.timestamp,
          format: _fmt,
          onTap: () async {
            final picked = await _pickDateTime(context, state.timestamp);
            if (picked != null) bloc.add(TimestampChanged(picked));
          },
        );
      },
    );
  }
}

class _DateTimeButton extends StatelessWidget {
  final String label;
  final DateTime? value;
  final String Function(DateTime) format;
  final VoidCallback onTap;

  const _DateTimeButton({
    required this.label,
    required this.value,
    required this.format,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.event),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        minimumSize: const Size.fromHeight(48),
      ),
      label: Text(
        value == null ? 'Pick $label' : '$label: ${format(value!)}',
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
