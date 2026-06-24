import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/core/utils/time_utils.dart';
import 'package:software_for_nature/data/models/category.dart';
import 'package:software_for_nature/data/models/tag.dart';
import 'package:software_for_nature/logic/bloc/filter/filter_bloc.dart';

class ActiveFilterChips extends StatelessWidget {
  const ActiveFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterBloc, FilterState>(
      builder: (context, state) {
        if (state is! FilterLoaded) {
          return const SizedBox.shrink();
        }

        final filterBloc = context.read<FilterBloc>();
        final allCategories = state.categories ?? const <Category>[];
        final allTags = state.tags ?? const <Tag>[];
        final activeCategories = state.activeCategories ?? const <Category>[];
        final activeTags = state.activeTags ?? const <Tag>[];
        final hasDate = state.startDate != null && state.endDate != null;

        final sections = <Widget>[
          _Section(
            label: 'Date',
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: hasDate
                    ? _ActiveChip(
                        label:
                            '${TimeUtils.formatDateTime(state.startDate!)} - ${TimeUtils.formatDateTime(state.endDate!)}',
                        icon: Icons.calendar_today,
                        onDeleted: () =>
                            filterBloc.add(DateRangeChanged(null, null)),
                      )
                    : const _ActiveChip(
                        label: 'All',
                        icon: Icons.calendar_today,
                      ),
              ),
            ],
          ),
          if (activeCategories.isNotEmpty)
            _Section(
              label: 'Categories',
              children: _allSelected(activeCategories, allCategories)
                  ? const [_ActiveChip(label: 'All')]
                  : [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (int i = 0; i < activeCategories.length; i++) ...[
                                if (i > 0) const SizedBox(width: 6),
                                _ActiveChip(
                                  label: activeCategories[i].name,
                                  color: activeCategories[i].color,
                                  onDeleted: () => filterBloc
                                      .add(CategoryChanged(activeCategories[i])),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
            ),
          if (activeTags.isNotEmpty)
            _Section(
              label: 'Tags',
              children: _allSelected(activeTags, allTags)
                  ? const [_ActiveChip(label: 'All')]
                  : [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final tag in activeTags) ...[
                                _ActiveChip(
                                  label: tag.label,
                                  color: tag.color,
                                  onDeleted: () => filterBloc.add(TagChanged(tag)),
                                ),
                              ]
                            ],
                          )
                      )
                      
                    )
                    ],
            ),
        ];

        if (sections.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: [
              for (int i = 0; i < sections.length; i++) ...[
                if (i > 0)
                  const Center(
                    child: SizedBox(
                      height: 24,
                      child: VerticalDivider(width: 16),
                    ),
                  ),
                Center(child: sections[i]),
              ],
            ],
          ),
        );
      },
    );
  }

  static bool _allSelected(List<Object?> active, List<Object?> all) => all.isNotEmpty && active.length >= all.length;
}

class _Section extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const _Section({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        const SizedBox(width: 6),
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          children[i],
        ],
      ],
    );
  }
}


class _ActiveChip extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;
  final VoidCallback? onDeleted;

  const _ActiveChip({
    required this.label,
    this.onDeleted,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final background = color ?? Theme.of(context).colorScheme.surfaceContainerHighest;
    final foreground = ThemeData.estimateBrightnessForColor(background) == Brightness.dark
      ? Colors.white
      : Colors.black87;

    return Chip(
      backgroundColor: background,
      avatar: icon != null ? Icon(icon, size: 16, color: foreground) : null,
      label: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: foreground),
      ),
      deleteIcon: onDeleted != null ? Icon(Icons.close, size: 16, color: foreground) : null,
      onDeleted: onDeleted,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: const StadiumBorder(),
    );
  }
}
