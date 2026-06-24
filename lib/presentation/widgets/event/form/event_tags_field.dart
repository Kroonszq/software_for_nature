import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/models/tag.dart';
import 'package:software_for_nature/logic/bloc/event_form_bloc/event_form_bloc.dart';

class EventTagsField extends StatefulWidget {
  const EventTagsField({super.key});

  @override
  State<EventTagsField> createState() => _EventTagsFieldState();
}

class _EventTagsFieldState extends State<EventTagsField> {
  static const List<Color> _palette = [
    Color(0xFFF44336),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF3F51B5),
    Color(0xFF2196F3),
    Color(0xFF009688),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF795548),
    Color(0xFF607D8B),
  ];

  final TextEditingController _labelController = TextEditingController();
  Color _color = _palette.first;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _createTag() {
    final label = _labelController.text.trim();
    if (label.isEmpty) return;

    context.read<EventFormBloc>().add(TagCreated(Tag(label: label, color: _color)));
    _labelController.clear();
    setState(() {}); // refresh the add button's enabled state
  }

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
            const SizedBox(height: 16),
            _buildCreateTag(),
          ],
        );
      },
    );
  }

  Widget _buildCreateTag() {
    final canAdd = _labelController.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create a new tag',
          style: TextStyle(color: Colors.black54, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _labelController,
                decoration: const InputDecoration(
                  hintText: 'New tag label',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _createTag(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: const Icon(Icons.add),
              tooltip: 'Add tag',
              onPressed: canAdd ? _createTag : null,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final color in _palette)
              GestureDetector(
                onTap: () => setState(() => _color = color),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _color.toARGB32() == color.toARGB32()
                          ? Colors.black
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
