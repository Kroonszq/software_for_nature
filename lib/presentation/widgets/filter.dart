import 'package:flutter/material.dart';
import 'package:software_for_nature/presentation/widgets/filter/category_filter.dart';
import 'package:software_for_nature/presentation/widgets/filter/date_filter.dart';
import 'package:software_for_nature/presentation/widgets/filter/search_filter.dart';

class Filter extends StatefulWidget {
  const Filter({super.key});

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  // On mobile the filters are hidden behind a hamburger menu and only shown
  // when the user expands them.
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // On narrow/mobile screens the three filters don't fit side by side,
        // so collapse them behind a hamburger menu; on wider screens keep them
        // in a row.
        final bool isCompact = constraints.maxWidth < 700;

        if (isCompact) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hamburger header that toggles the filter panel.
                Row(
                  children: [
                    IconButton(
                      icon: Icon(_expanded ? Icons.close : Icons.menu),
                      tooltip: _expanded ? 'Hide filters' : 'Show filters',
                      onPressed: () => setState(() => _expanded = !_expanded),
                    ),
                    const Text('Filters'),
                  ],
                ),
                // Collapsible filter panel.
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CategoryFilter(),
                        SizedBox(height: 12),
                        DateFilter(),
                        SizedBox(height: 12),
                        SearchFilter(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          // height: 20,
          width: double.infinity,
          padding: const EdgeInsets.all(5),
          child: const Row(
            children: [
              Expanded(flex: 1, child: CategoryFilter()),
              SizedBox(width: 20),
              Expanded(flex: 1, child: DateFilter()),
              SizedBox(width: 20),
              Expanded(flex: 1, child: SearchFilter()),
            ],
          ),
        );
      },
    );
  }
}
