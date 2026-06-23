import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/presentation/models/timeline.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_content.dart';
import 'package:software_for_nature/logic/bloc/timeline/timelines_wrapper_bloc.dart';

class TimelineSideBar extends StatefulWidget {
  /// The direction of the previews vertical is the desktop right rail, horizontal is the mobile bottom bar
  final Axis axis;
  final bool? minimized;
  final ValueChanged<bool>? onMinimizedChanged;

  /// The shared vertical scroll offset of the main timelines
  final ValueListenable<double>? scrollOffset;

  /// The full  height of the timeline content in timeline pixels
  final double? contentHeight;

  /// The earliest timestamp shared by every timeline
  final DateTime? earliest;

  const TimelineSideBar({
    super.key,
    this.axis = Axis.vertical,
    this.minimized,
    this.onMinimizedChanged,
    this.scrollOffset,
    this.contentHeight,
    this.earliest,
  });

  @override
  State<TimelineSideBar> createState() => _TimelineSideBarState();
}

class _TimelineSideBarState extends State<TimelineSideBar> {
  bool _internalMinimized = false;

  bool get _minimized => widget.minimized ?? _internalMinimized;

  void _setMinimized(bool value) {
    if (widget.minimized != null) {
      widget.onMinimizedChanged?.call(value);
    } else {
      setState(() => _internalMinimized = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.axis == Axis.horizontal) {
      return _buildHorizontal(context);
    }
    return _buildVertical(context);
  }


  Widget _buildHorizontal(BuildContext context) {
    return BlocBuilder<TimeLinesWrapperBloc, TimeLinesWrapperState>(
      builder: (context, state) {
        if (state is! TimeLinesWrapperLoaded || state.timelines.isEmpty) {
          return const SizedBox.shrink();
        }

        final entries = state.timelines.entries.toList();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Toggle to hide/show the previews.
            SizedBox(
              height: 32,
              child: InkWell(
                onTap: () => _setMinimized(!_minimized),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    const Text(
                      'Previews',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _minimized ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            if (!_minimized)
              SizedBox(
                height: 96,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  children: [
                    for (final entry in entries) ...[
                      SizedBox(
                        width: 88,
                        child: _previewCard(context, entry),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }


  Widget _buildVertical(BuildContext context) {
    // Minimized content
    if (_minimized) {
      return SizedBox(
        width: 40,
        child: Container(
          color: Colors.blueGrey.shade50,
          child: Column(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Show previews',
                onPressed: () => _setMinimized(false),
              ),
              const RotatedBox(
                quarterTurns: 1,
                child: Text(
                  'Previews',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Expanded content
    return BlocBuilder<TimeLinesWrapperBloc, TimeLinesWrapperState>(
      builder: (context, state) {
        if (state is! TimeLinesWrapperLoaded) {
          return const Expanded(
            flex: 1,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // mirror the main view: show a preview for every timeline the wrapper
        final visibleEntries = state.timelines.entries.toList();

        return Expanded(
          flex: 1,
          child: Column(
            children: [
              // Header with minimize button
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_outlined),
                    tooltip: 'Hide previews',
                    onPressed: () => _setMinimized(true),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Text(
                        'Previews',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Previeuws
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(15),
                  scrollDirection: Axis.vertical,
                  children: [
                    for (final entry in visibleEntries) ...[
                      SizedBox(
                        height: 160,
                        child: _previewCard(context, entry),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _previewCard(BuildContext context, MapEntry<int, Timeline> entry) {
    return GestureDetector(
      onTap: () {
        // Toggle: clicking an already-active timeline deactivates it.
        context.read<TimeLinesWrapperBloc>().add(
              entry.value.active
                  ? SetTimelineInActive(entry.key)
                  : SetTimelineActive(entry.key),
            );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // label
          Container(
            color: Colors.blueGrey.shade700,
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 3,
            ),
            child: Center(
              child: Text(
                entry.value.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Scaled timeline
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: entry.value.color.withValues(alpha: 0.15),
                border: Border.all(
                  color: entry.value.active ? Colors.blue : Colors.transparent,
                  width: 5,
                ),
              ),
              child: ClipRect(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const double scale = 0.18;


                    final double layoutHeight = (widget.contentHeight != null && widget.contentHeight! > 0)
                            ? widget.contentHeight!
                            : constraints.maxHeight / scale;

                    return OverflowBox(
                      alignment: Alignment.topLeft,
                      maxWidth: constraints.maxWidth / scale,
                      minHeight: layoutHeight,
                      maxHeight: layoutHeight,
                      child: Transform.scale(
                        scale: scale,
                        alignment: Alignment.topLeft,

                        child: _ScrollingPreview(
                          scrollOffset: widget.scrollOffset,
                          child: IgnorePointer(
                            child: TimelineContent(
                              listOfEvents: entry.value.events,
                              earliest: widget.earliest,
                              minHeight: widget.contentHeight ?? 0,
                              groupColor: entry.value.color,
                              enableHorizontalScroll: false,
                              showOffscreenIndicators: false,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _ScrollingPreview extends StatelessWidget {
  final ValueListenable<double>? scrollOffset;
  final Widget child;

  const _ScrollingPreview({required this.scrollOffset, required this.child});

  @override
  Widget build(BuildContext context) {
    final offset = scrollOffset;
    if (offset == null) {
      return child;
    }

    return ValueListenableBuilder<double>(
      valueListenable: offset,
      child: child,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -value),
          child: child,
        );
      },
    );
  }
}
