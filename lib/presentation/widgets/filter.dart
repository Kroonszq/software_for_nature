import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/logic/bloc/filter/filter_bloc.dart';
import 'package:software_for_nature/presentation/widgets/filter/active_filter_chips.dart';
import 'package:software_for_nature/presentation/widgets/filter/category_filter.dart';
import 'package:software_for_nature/presentation/widgets/filter/date_filter.dart';
import 'package:software_for_nature/presentation/widgets/filter/export_button.dart';
import 'package:software_for_nature/presentation/widgets/filter/search_filter.dart';
import 'package:software_for_nature/presentation/widgets/filter/tag_filter.dart';

class Filter extends StatelessWidget {
  const Filter({super.key});

  /// Opens the filters in a panel that slides in from the left.
  ///
  /// The dialog is built above this page's providers, so the existing
  /// [FilterBloc] is forwarded into it with [BlocProvider.value].
  void _openFilters(BuildContext context) {
    final filterBloc = context.read<FilterBloc>();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Filters',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerLeft,
          child: BlocProvider.value(
            value: filterBloc,
            child: const _FilterDrawerPanel(),
          ),
        );
      },
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Keep the search field compact; the chip strip takes the remaining
          // space but stays capped at 460 and scrolls horizontally inside it.
          final double searchWidth = constraints.maxWidth < 600 ? 140 : 200;
          return Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.filter_list),
                label: const Text('Filters'),
                onPressed: () => _openFilters(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const ActiveFilterChips(),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(width: searchWidth, child: const SearchFilter()),
              const SizedBox(width: 8),
              const ExportButton(),
            ],
          );
        },
      ),
    );
  }
}

/// The left-side panel that lists every filter, stacked vertically.
class _FilterDrawerPanel extends StatelessWidget {
  const _FilterDrawerPanel();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double panelWidth = screenWidth < 520 ? screenWidth * 0.9 : 420;

    return SizedBox(
      width: panelWidth, 
      height: double.infinity,
      child: Material(
        elevation: 16,
        color: Theme.of(context).canvasColor,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                child: Row(
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Close filters',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: const [
                    _FilterSection(title: 'Category', child: CategoryFilter()),
                    Divider(height: 32),
                    _FilterSection(title: 'Tags', child: TagFilter()),
                    Divider(height: 32),
                    _FilterSection(title: 'Date & time', child: DateFilter()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single labelled filter block: a bold title above its control.
class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FilterSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}
