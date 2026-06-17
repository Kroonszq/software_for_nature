import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/core/utils/color_utils.dart';
import 'package:software_for_nature/data/models/group.dart';
import 'package:software_for_nature/logic/bloc/filter/filter_bloc.dart';

class CategoryFilter extends StatefulWidget {
  const CategoryFilter({super.key});

  @override
  State<CategoryFilter> createState() => _CategoryFilterState();
}

class _CategoryFilterState extends State<CategoryFilter> {
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
        final groups =  state is FilterLoaded ? (state.groups ?? const <Group>[]) : const <Group>[];
        final activeGroups = state is FilterLoaded ? (state.activeGroups ?? const <Group>[]) : const <Group>[];
        final selectableGroups = groups.where((group) => !activeGroups.any((activeGroup) => activeGroup.id == group.id)) ?? const <Group>[];

        return Row(
          children: [
            Text("Select a category"),
            SizedBox(width: 20),
            DropdownButton<String>(
              value: null,
              hint: const Text('Category'),
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(height: 2, color: Colors.deepPurpleAccent),
              onChanged: (String? id) {
                if (id == null) return;
                final group = groups.firstWhere((g) => g.id == id);
                context.read<FilterBloc>().add(CategoryChanged(group));
              },
              items: [
                DropdownMenuItem<String>(
                    value: null,
                    child: Text('Select a category'),
                  ),
                  for (final group in selectableGroups)
                    DropdownMenuItem<String>(
                      value: group.id,
                      child: Text(group.title),
                    ),
              ],
            ),
            SizedBox(width: 20),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for(final activeGroup in activeGroups)
                        ElevatedButton.icon(
                          onPressed: () {
                              context.read<FilterBloc>().add(CategoryChanged(activeGroup));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeGroup.color,
                          ),
                          icon: const Icon(Icons.close, color: Colors.white),
                          label: Text(activeGroup.title, style: TextStyle(color: Colors.white)),
                        ),
                    ],
                  ),
                ),
              ),
            )
          ],

        );
        
        
      },
    );
  }
}
