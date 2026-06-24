import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/models/category.dart';
import 'package:software_for_nature/logic/bloc/filter/filter_bloc.dart';

class CategoryFilter extends StatelessWidget {
  const CategoryFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterBloc, FilterState>(
      builder: (context, state) {
        final categories = state is FilterLoaded
            ? (state.categories ?? const <Category>[])
            : const <Category>[];
        
        final activeCategories = state is FilterLoaded
            ? (state.activeCategories ?? const <Category>[])
            : const <Category>[];
        
        final selectableCategories = categories
            .where((category) => !activeCategories
            .any((activeCategory) => activeCategory.id == category.id))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select
            DropdownButton<String>(
              isExpanded: true,
              value: null,
              hint: const Text('Select a category'),
              icon: const Icon(Icons.arrow_drop_down),
              items: [
                for (final category in selectableCategories)
                  DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(category.name),
                  ),
              ],
              onChanged: (String? id) {
                if (id == null){
                  return;
                }

                final category = categories.firstWhere((c) => c.id == id);
                context.read<FilterBloc>().add(CategoryChanged(category));
              },
            ),

            // Values
            if (activeCategories.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final activeCategory in activeCategories)
                    ElevatedButton.icon(
                      onPressed: () => context.read<FilterBloc>().add(CategoryChanged(activeCategory)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activeCategory.color,
                      ),
                      icon: const Icon(Icons.close, color: Colors.white, size: 18),
                      label: Text(
                        activeCategory.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
