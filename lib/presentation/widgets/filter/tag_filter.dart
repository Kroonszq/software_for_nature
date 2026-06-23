import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/models/tag.dart';
import 'package:software_for_nature/logic/bloc/filter/filter_bloc.dart';

class TagFilter extends StatelessWidget {
  const TagFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterBloc, FilterState>(
      builder: (context, state) {
        final tags = state is FilterLoaded
            ? (state.tags ?? const <Tag>[])
            : const <Tag>[];
        final activeTags = state is FilterLoaded
            ? (state.activeTags ?? const <Tag>[])
            : const <Tag>[];
        final selectableTags = tags
            .where((tag) => !activeTags.any((active) => active.label == tag.label))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select
            DropdownButton<String>(
              isExpanded: true,
              value: null,
              hint: const Text('Select a tag'),
              icon: const Icon(Icons.arrow_drop_down),
              items: [
                for (final tag in selectableTags)
                  DropdownMenuItem<String>(
                    value: tag.label,
                    child: Text(tag.label),
                  ),
              ],
              onChanged: (String? label) {
                if (label == null) return;
                final tag = tags.firstWhere((t) => t.label == label);
                context.read<FilterBloc>().add(TagChanged(tag));
              },
            ),

            // Values
            if (activeTags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final activeTag in activeTags) _TagChip(tag: activeTag),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

/// A removable chip for a selected tag, filled with the tag's own colour and
/// using a readable text/icon colour for contrast.
class _TagChip extends StatelessWidget {
  final Tag tag;

  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    final foreground =
        ThemeData.estimateBrightnessForColor(tag.color) == Brightness.dark
            ? Colors.white
            : Colors.black87;

    return ElevatedButton.icon(
      onPressed: () => context.read<FilterBloc>().add(TagChanged(tag)),
      style: ElevatedButton.styleFrom(backgroundColor: tag.color),
      icon: Icon(Icons.close, color: foreground, size: 18),
      label: Text(tag.label, style: TextStyle(color: foreground)),
    );
  }
}
