import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/models/tag.dart';
import 'package:software_for_nature/logic/bloc/event_form_bloc/event_form_bloc.dart';

class EventTagsField extends StatelessWidget {
  const EventTagsField({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventFormBloc, EventFormBlocState>(
      buildWhen: (prev, curr) =>
          prev.availableTags != curr.availableTags ||
          prev.selectedTags != curr.selectedTags,
      builder: (context, state) {
        final availableTags = state.availableTags
            .where((tag) => !state.selectedTags.contains(tag))
            .toList();
        final uniqueAvailableTags = <Tag>[];
        final seen = <String>{};
        for (final tag in availableTags) {
          final key = '${tag.label}:${tag.color.toARGB32()}';
          if (seen.add(key)) {
            uniqueAvailableTags.add(tag);
          }
        }
        uniqueAvailableTags.sort((a, b) => a.label.compareTo(b.label));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<Tag>(
              key: ValueKey(uniqueAvailableTags.map((tag) => '${tag.label}:${tag.color.toARGB32()}').join(',')),
              decoration: const InputDecoration(labelText: 'Tags'),
              initialValue: null,
              hint: const Text('Add a tag'),
              items: [
                for (final tag in uniqueAvailableTags)
                  DropdownMenuItem<Tag>(
                    value: tag,
                    child: Text(tag.label),
                  ),
              ],
              onChanged: (tag) {
                if (tag == null) return;
                context.read<EventFormBloc>().add(TagSelected(tag));
              },
            ),
            if (state.selectedTags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.selectedTags.map((tag) {
                  final foreground = ThemeData.estimateBrightnessForColor(tag.color) == Brightness.dark
                      ? Colors.white
                      : Colors.black87;
                  return InputChip(
                    label: Text(tag.label, style: TextStyle(color: foreground)),
                    backgroundColor: tag.color,
                    onDeleted: () => context.read<EventFormBloc>().add(TagDeselected(tag)),
                  );
                }).toList(),
              ),
            ],
          ],
        );
      },
    );
  }
}
