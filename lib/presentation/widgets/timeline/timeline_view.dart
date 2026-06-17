import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/models/timeline.dart';
import 'package:software_for_nature/logic/bloc/timeline/timelines_wrapper_bloc.dart';
import 'package:software_for_nature/presentation/widgets/minimized_events_stack.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_axis_bar.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_header.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_column.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_side_bar.dart';

class TimelineView extends StatefulWidget {
  const TimelineView({super.key});

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  final ScrollController _axisScrollController = ScrollController();
  Map<int, ScrollController> _timelineScrollControllers = {};

  // On mobile, the timeline the user tapped to "focus". A focused timeline is
  // highlighted and can be scrolled horizontally; while none is focused
  // horizontal drags swipe between timelines.
  int? _focusedTimelineKey;

  void _initControllers(TimeLinesWrapperLoaded state) {
    // Dispose old controller so we dont have dupes
    for (final c in _timelineScrollControllers.values) {
      c.dispose();
    }

  _timelineScrollControllers = {
    for (final entry in state.timelines.entries)
      entry.key: ScrollController()
        ..addListener(() {
          final controller = _timelineScrollControllers[entry.key]!;
          final offset = controller.offset;

          // Sync axis bar
          if (_axisScrollController.hasClients && _axisScrollController.offset != offset) {
            _axisScrollController.jumpTo(offset);
          }

          // Sync all other timeline controllers
          for (final other in _timelineScrollControllers.entries) {
            if (other.key != entry.key && other.value.hasClients && other.value.offset != offset) {
              other.value.jumpTo(offset);
            }
          }
        }
      ),
    };
  }

  @override
  void dispose() {
    _axisScrollController.dispose();
    for (final c in _timelineScrollControllers.values) {
      c.dispose();
    }
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TimeLinesWrapperBloc, TimeLinesWrapperState>(
      listener: (context, state) {
        if (state is TimeLinesWrapperLoaded) {
          setState(() => _initControllers(state));
        }
      },
      builder: (context, state) {
        if (state is! TimeLinesWrapperLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final activeTimelines = state.timelines.entries.toList();

        // No categories in scope at all -> nothing to show.
        if (state.timelines.isEmpty) {
          return const Center(child: Text('No timelines'));
        }

        // When a filter narrows every timeline to zero events we still render
        // the columns (each shows "No events found"), so fall back to a valid
        // range for the time axis.
        final earliest = state.earliest ?? DateTime.now();
        final latest = state.latest ?? earliest;

        final double minHeight = _calculateMinHeight(activeTimelines, earliest);

        // On mobile/narrow screens hide the side rails (minimized events stack
        // and the previews sidebar) to give the timeline the full width.
        final bool isCompact = MediaQuery.sizeOf(context).width < 700;

        return Row(
          children: [
            // Minimized events stack
            if (!isCompact) const MinimizedEventsStack(),
            // Time axis bar
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                controller: _axisScrollController,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: TimeAxisBar(earliest: earliest, latest: latest),
              ),
            ),
            const VerticalDivider(width: 1),
            // Timelines
            Expanded(
              flex: 10,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final activeCount = state.timelineOrder
                      .where((key) => state.timelines[key]?.active == true)
                      .length;

                  // On mobile show 1 1/3 columns in the viewport (each column
                  // is 3/4 of the width) so the user can see there's more to
                  // scroll horizontally. With a single timeline use the full
                  // width. On wider screens divide the space evenly.
                  final double columnWidth;
                  if (isCompact) {
                    columnWidth = activeCount > 1
                        ? constraints.maxWidth * 0.90
                        : constraints.maxWidth;
                  } else {
                    columnWidth = activeCount > 0
                        ? constraints.maxWidth / activeCount
                        : constraints.maxWidth;
                  }

                  return ReorderableListView(
                    scrollDirection: Axis.horizontal,
                    buildDefaultDragHandles: false,
                    onReorderItem: (oldIndex, newIndex) {
                      context.read<TimeLinesWrapperBloc>().add(
                        ReorderTimeline(oldIndex, newIndex),
                      );
                    },
                    children: [
                      for (int i = 0; i < state.timelineOrder.length; i++)
                        if (state.timelines[state.timelineOrder[i]]?.active == true)
                          Builder(
                            key: ValueKey(state.timelineOrder[i]),
                            builder: (context) {
                              final int timelineKey = state.timelineOrder[i];
                              final bool isFocused =
                                  isCompact && _focusedTimelineKey == timelineKey;

                              return GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: isCompact
                                    ? () => setState(() {
                                          _focusedTimelineKey =
                                              isFocused ? null : timelineKey;
                                        })
                                    : null,
                                child: Container(
                                  width: columnWidth,
                                  // Keep a (transparent) border at all times so
                                  // the element tree structure stays stable when
                                  // focus toggles; otherwise the subtree — and
                                  // the timeline's scroll positions — get reset.
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isFocused
                                          ? const Color(0xFFFF5900)
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                  child: Column(
                              children: [
                                // Timeline header
                                TimelineHeader(
                                    title: 'Timeline ${state.timelineOrder[i]}',
                                    groupName: state.timelines[state.timelineOrder[i]]!.events.isNotEmpty
                                        ? state.timelines[state.timelineOrder[i]]!.events.first.group?.title ?? state.timelines[state.timelineOrder[i]]!.title
                                        : state.timelines[state.timelineOrder[i]]!.title,
                                    position: i,
                                    color: state.timelines[state.timelineOrder[i]]!.color,
                                    onMinimize: () => context
                                        .read<TimeLinesWrapperBloc>()
                                        .add(SetTimelineInActive(state.timelineOrder[i])),
                                ),
                                // Timeline content
                                Expanded(
                                  child: state.timelines[state.timelineOrder[i]]?.timelineWidget != null
                                      ? TimelineColumn(
                                          earliest: earliest,
                                          listOfEvents: state.timelines[state.timelineOrder[i]]!.timelineWidget!.listOfEvents,
                                          scrollController: _timelineScrollControllers[state.timelineOrder[i]],
                                          groupColor: state.timelines[state.timelineOrder[i]]!.color,
                                          minHeight: minHeight,
                                          enableHorizontalScroll: !isCompact || isFocused,
                                        )
                                      : const SizedBox(),
                                ),
                              ],
                                  ),
                                ),
                              );
                            },
                          ),
                    ],
                  );
                },
              ),
            ),
            if (!isCompact) const VerticalDivider(width: 1),
            if (!isCompact) const TimelineSideBar(),
          ],
        );
      },
    );
  }

  double _calculateMinHeight(List<MapEntry<int, Timeline>> activeTimelines, DateTime earliest) {
    double maxHeight = 0.0;

    for (final entry in activeTimelines) {
      final widget = entry.value.timelineWidget;
      if (widget is! TimelineColumn) continue;

      for (final event in widget.listOfEvents) {
        final height = event.endDuration.difference(earliest).inMinutes * 2.0;
        if (height > maxHeight) maxHeight = height;
      }
    }

    return maxHeight;
  }

}