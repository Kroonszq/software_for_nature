import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/models/tag.dart';
import 'package:software_for_nature/logic/bloc/filter/filter_bloc.dart';

class TagFilter extends StatefulWidget {
  final bool compact;

  const TagFilter({super.key, this.compact = false});

  @override
  State<TagFilter> createState() => _TagFilterState();
}

class _TagFilterState extends State<TagFilter> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterBloc, FilterState>(
      builder: (context, state) {
        final tags = state is FilterLoaded ? (state.tags ?? const <Tag>[]) : const <Tag>[];
        final activeTags = state is FilterLoaded ? (state.activeTags ?? const <Tag>[]) : const <Tag>[];
        final selectableTags = tags.where((tag) => !activeTags.any((active) => active.label == tag.label));

        return Row(
          children: [
            SizedBox(width: widget.compact ? 8 : 20),
            DropdownButton<String>(
              value: null,
              hint: const Text('Tag'),
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(height: 2, color: Colors.deepPurpleAccent),
              onChanged: (String? label) {
                if (label == null){
                  return;
                }
                final tag = tags.firstWhere((t) => t.label == label);
                context.read<FilterBloc>().add(TagChanged(tag));
              },
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Select a tag'),
                ),
                for (final tag in selectableTags)
                  DropdownMenuItem<String>(
                    value: tag.label,
                    child: Text(tag.label),
                  ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final activeTag in activeTags)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _TagChip(tag: activeTag),
                        ),
                    ],
                  ),
                ),
              ),
            ),
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
