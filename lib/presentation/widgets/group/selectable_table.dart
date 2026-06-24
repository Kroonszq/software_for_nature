import 'package:flutter/material.dart';

class SelectableRow {
  final String id;
  final String label;

  /// text match
  final String searchText;
  final Widget? leading;

  const SelectableRow({required this.id, required this.label, required this.searchText, this.leading,});
}

class SelectableTable extends StatefulWidget {
  final String searchHint;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final List<SelectableRow> rows;
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onChanged;

  const SelectableTable({
    super.key,
    required this.searchHint,
    required this.query,
    required this.onQueryChanged,
    required this.rows,
    required this.selectedIds,
    required this.onChanged,
  });

  @override
  State<SelectableTable> createState() => _SelectableTableState();
}

class _SelectableTableState extends State<SelectableTable> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = widget.query.trim().toLowerCase();
    final filtered = normalizedQuery.isEmpty
        ? widget.rows
        : widget.rows
            .where((r) => r.searchText.toLowerCase().contains(normalizedQuery))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: widget.onQueryChanged,
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: const Icon(Icons.search, size: 20),
            hintText: widget.searchHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'No matches',
                    style: TextStyle(color: Colors.black54),
                  ),
                )
              : Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: ListView.separated(
                    controller: _scrollController,
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final row = filtered[index];
                      return CheckboxListTile(
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        secondary: row.leading,
                        value: widget.selectedIds.contains(row.id),
                        title: Text(row.label),
                        onChanged: (checked) =>
                            widget.onChanged(row.id, checked ?? false),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
