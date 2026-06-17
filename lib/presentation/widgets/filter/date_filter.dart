import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/logic/bloc/filter/filter_bloc.dart';

class DateFilter extends StatelessWidget {
  const DateFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterBloc, FilterState>(
      builder: (context, state) {
        final startDate = state is FilterLoaded ? state.startDate : null;
        final endDate = state is FilterLoaded ? state.endDate : null;
        final hasRange = startDate != null && endDate != null;

        final label = hasRange
            ? '${_format(startDate)} - ${_format(endDate)}'
            : 'Select a date & time range';

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filter by date'),
            const SizedBox(width: 20),
            Flexible(
              child: ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(label, overflow: TextOverflow.ellipsis),
              onPressed: () async {
                final now = DateTime.now();
                final pickedRange = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(now.year - 5),
                  lastDate: DateTime(now.year + 5),
                  initialDateRange: hasRange
                      ? DateTimeRange(start: startDate, end: endDate)
                      : null,
                );

                if (pickedRange == null) return;
                if (!context.mounted) return;

                // Pick the start time of the range.
                final startTime = await showTimePicker(
                  context: context,
                  helpText: 'Select start time',
                  initialTime: startDate != null
                      ? TimeOfDay.fromDateTime(startDate)
                      : const TimeOfDay(hour: 0, minute: 0),
                );

                if (startTime == null) return;
                if (!context.mounted) return;

                // Pick the end time of the range.
                final endTime = await showTimePicker(
                  context: context,
                  helpText: 'Select end time',
                  initialTime: endDate != null
                      ? TimeOfDay.fromDateTime(endDate)
                      : const TimeOfDay(hour: 23, minute: 59),
                );

                if (endTime == null) return;
                if (!context.mounted) return;

                final start = DateTime(
                  pickedRange.start.year,
                  pickedRange.start.month,
                  pickedRange.start.day,
                  startTime.hour,
                  startTime.minute,
                );
                final end = DateTime(
                  pickedRange.end.year,
                  pickedRange.end.month,
                  pickedRange.end.day,
                  endTime.hour,
                  endTime.minute,
                );

                context.read<FilterBloc>().add(DateRangeChanged(start, end));
              },
            ),
            ),
            if (hasRange) ...[
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Clear date filter',
                onPressed: () => context
                    .read<FilterBloc>()
                    .add(DateRangeChanged(null, null)),
              ),
            ],
          ],
        );
      },
    );
  }

  String _format(DateTime date) =>
      '${date.day}/${date.month}/${date.year} ${_two(date.hour)}:${_two(date.minute)}';

  String _two(int value) => value.toString().padLeft(2, '0');
}
