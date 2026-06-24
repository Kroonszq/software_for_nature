import 'package:flutter/material.dart';
import 'package:software_for_nature/core/utils/event_exporter.dart';
import 'package:software_for_nature/core/utils/time_utils.dart';
import 'package:software_for_nature/data/models/event_post.dart';

enum _ExportMode { currentQuery, cherryPick }

class ExportDrawer extends StatefulWidget {

  /// events matching the filters currently applied in the window
  final List<EventPost> currentQueryEvents;

  /// every event in the dataset
  final List<EventPost> allEvents;

  const ExportDrawer({super.key, required this.currentQueryEvents, required this.allEvents});

  @override
  State<ExportDrawer> createState() => _ExportDrawerState();
}

class _ExportDrawerState extends State<ExportDrawer> {
  _ExportMode _mode = _ExportMode.currentQuery;
  ExportFormat _format = ExportFormat.json;
  late final Set<String> _selectedIds;
  bool _busy = false;

  final TextEditingController _searchController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.currentQueryEvents.map((e) => e.id).toSet();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// checrry pick filtered
  List<EventPost> get _filteredEvents {
    final q = _search.trim().toLowerCase();
    if (q.isEmpty) {
      return widget.allEvents;
    }
    return widget.allEvents
        .where((e) => e.title.toLowerCase().contains(q) || e.description.toLowerCase().contains(q))
        .toList();
  }

  List<EventPost> get _eventsToExport {
    if (_mode == _ExportMode.currentQuery) {
      return widget.currentQueryEvents;
    }
    return widget.allEvents
        .where((e) => _selectedIds.contains(e.id))
        .toList();
  }

  Future<void> _export() async {
    final events = _eventsToExport;
    if (events.isEmpty) {
      return;
    }

    setState(() => _busy = true);

    String? path;
    Object? error;
    try {
      path = await EventExporter.save(events, _format);
    } catch (e) {
      error = e;
    }

    if (!mounted) {
      return;
    }
    setState(() => _busy = false);

    final messenger = ScaffoldMessenger.of(context);
    if (error != null) {
      messenger.showSnackBar(
        SnackBar(content: Text('Export failed: $error')),
      );
    } else if (path != null) {
      messenger.showSnackBar(
        SnackBar(content: Text('Exported ${events.length} events')),
      );
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final exportCount = _eventsToExport.length;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                const Icon(Icons.download),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Export events',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mode selection
                SegmentedButton<_ExportMode>(
                  segments: const [
                    ButtonSegment(
                      value: _ExportMode.currentQuery,
                      label: Text('Current query'),
                      icon: Icon(Icons.filter_alt_outlined),
                    ),
                    ButtonSegment(
                      value: _ExportMode.cherryPick,
                      label: Text('Cherry-pick'),
                      icon: Icon(Icons.checklist),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => setState(() => _mode = s.first),
                ),
                const SizedBox(height: 16),
                // Format selection
                Row(
                  children: [
                    const Text('Format'),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SegmentedButton<ExportFormat>(
                        segments: [
                          for (final f in ExportFormat.values)
                            ButtonSegment(value: f, label: Text(f.label)),
                        ],
                        selected: {_format},
                        onSelectionChanged: (s) =>
                            setState(() => _format = s.first),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: _mode == _ExportMode.currentQuery
                ? _buildCurrentQuery()
                : _buildCherryPick(),
          ),

          const Divider(height: 1),
          // Footer action
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: (_busy || exportCount == 0) ? null : _export,
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_alt),
              label: Text(
                _busy ? 'Exporting…' : 'Export $exportCount events',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentQuery() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.filter_alt, size: 48, color: Colors.black38),
            const SizedBox(height: 12),
            Text(
              '${widget.currentQueryEvents.length} events match the current filters.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Adjust the filters in the bar to change what gets exported.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCherryPick() {
    if (widget.allEvents.isEmpty) {
      return const Center(child: Text('No events available.'));
    }

    final events = _filteredEvents;

    return Column(
      children: [
        // search
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _search = value),
            decoration: InputDecoration(
              hintText: 'Search events',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Clear search',
                      onPressed: () => setState(() {
                        _searchController.clear();
                        _search = '';
                      }),
                    ),
              isDense: true,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
       

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '${_selectedIds.length} selected',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton(
                onPressed: events.isEmpty
                    ? null
                    : () => setState(
                          () => _selectedIds.addAll(events.map((e) => e.id)),
                        ),
                child: const Text('Select all'),
              ),
              TextButton(
                onPressed: events.isEmpty
                    ? null
                    : () => setState(
                          () => _selectedIds
                              .removeAll(events.map((e) => e.id).toSet()),
                        ),
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        if (events.isEmpty)
          const Expanded(
            child: Center(child: Text('No events match your search.')),
          )
        else
        Expanded(
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final checked = _selectedIds.contains(event.id);
              return CheckboxListTile(
                dense: true,
                value: checked,
                title: Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  TimeUtils.formatDateTime(event.occurredAt),
                  style: const TextStyle(fontSize: 11),
                ),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedIds.add(event.id);
                    } else {
                      _selectedIds.remove(event.id);
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
