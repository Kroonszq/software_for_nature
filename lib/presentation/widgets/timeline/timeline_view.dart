import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/core/constants/timeline_constants.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/data/models/timeline.dart';
import 'package:software_for_nature/logic/bloc/timeline/timeline_bloc.dart';
import 'package:software_for_nature/logic/bloc/timeline/timelines_wrapper_bloc.dart';
import 'package:software_for_nature/presentation/widgets/minimized_events_stack.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_axis_bar.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_column.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_content.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_side_bar.dart';

class TimelineView extends StatefulWidget {
  final bool overlaySidebar;

  const TimelineView({super.key, this.overlaySidebar = false});

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  final ScrollController _axisScrollController = ScrollController();
  Map<int, ScrollController> _timelineScrollControllers = {};

  // On mobile when an event is tapped it is focused
  int? _focusedTimelineKey;

  bool _overlaySidebarMinimized = false;

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
            if (_axisScrollController.hasClients &&
                _axisScrollController.offset != offset) {
              _axisScrollController.jumpTo(offset);
            }

            // Sync all other timeline controllers
            for (final other in _timelineScrollControllers.entries) {
              if (other.key != entry.key &&
                  other.value.hasClients &&
                  other.value.offset != offset) {
                other.value.jumpTo(offset);
              }
            }
          }),
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
    return BlocListener<TimelineBloc, TimelineState>(

      // Scroll the timeline to an event only when something requests it
      listenWhen: (prev, curr) => curr is TimelineInitial && (prev is! TimelineInitial || prev.focusRequestId != curr.focusRequestId),
      listener: (context, state) {
        if (state is TimelineInitial && state.selectedPost != null) {
          _scrollToEvent(state.selectedPost!);
        }
      },
      child: BlocConsumer<TimeLinesWrapperBloc, TimeLinesWrapperState>(
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

          // No categories show to user
          if (state.timelines.isEmpty) {
            return const Center(child: Text('No timelines'));
          }

          final earliest = state.earliest ?? DateTime.now();
          final latest = state.latest ?? earliest;

          
          final double minHeight = _calculateMinHeight(activeTimelines,earliest);

          // Check if we are on mobile
          final bool isCompact = MediaQuery.sizeOf(context).width < TimelineConstants.compactBreakpoint;

          // When in hybrid view use overlay instead of placing it next to the timelines
          const double sidebarOverlayWidth = 220;
          final bool showSidebar = !isCompact;
          final bool overlaySidebar = showSidebar && widget.overlaySidebar;

          final Widget content = Row(
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

                    // On mobile show 1 1/3 columns in the viewport
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
                          if (state.timelines[state.timelineOrder[i]]?.active ==
                              true)
                            Builder(
                              key: ValueKey(state.timelineOrder[i]),
                              builder: (context) {
                                final int timelineKey = state.timelineOrder[i];
                                final Timeline timeline = state.timelines[timelineKey]!;
                                final bool isFocused = isCompact && _focusedTimelineKey == timelineKey;

                                return TimelineColumn(
                                  timeline: timeline,
                                  timelineKey: timelineKey,
                                  position: i,
                                  width: columnWidth,
                                  isFocused: isFocused,
                                  enableHorizontalScroll: !isCompact || isFocused,
                                  earliest: earliest,
                                  minHeight: minHeight,
                                  scrollController: _timelineScrollControllers[timelineKey],
                                  onTap: isCompact
                                      ? () => setState(() {
                                          _focusedTimelineKey = isFocused
                                              ? null
                                              : timelineKey;
                                        })
                                      : null,
                                  onMinimize: () => context
                                      .read<TimeLinesWrapperBloc>()
                                      .add(SetTimelineInActive(timelineKey)),
                                );
                              },
                            ),
                      ],
                    );
                  },
                ),
              ),
              // Inline previews rail (only when there's room to sit beside the
              // timelines).
              if (showSidebar && !overlaySidebar) ...[
                const VerticalDivider(width: 1),
                const TimelineSideBar(),
              ],
            ],
          );

          if (!overlaySidebar) {
            return content;
          }

          // Too narrow: timelines take the full width and the previews rail
          // floats on top, anchored to the right edge. When the rail is
          // minimized the overlay hugs the thin toggle (40px) so it doesn't
          // cover the timelines; expanded it widens to the full rail.
          const double minimizedOverlayWidth = 40;
          return Stack(
            children: [
              Positioned.fill(child: content),
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                width: _overlaySidebarMinimized
                    ? minimizedOverlayWidth
                    : sidebarOverlayWidth,
                child: Material(
                  elevation: 8,
                  color: Theme.of(context).canvasColor,
                  // The Row gives the (Expanded) sidebar a Flex parent while
                  // the fixed-width Positioned bounds it.
                  child: Row(
                    children: [
                      TimelineSideBar(
                        minimized: _overlaySidebarMinimized,
                        onMinimizedChanged: (value) =>
                            setState(() => _overlaySidebarMinimized = value),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  ///  Scrolls the controller of the column the event belongs to when hovered on the map
  void _scrollToEvent(EventPost event) {

    // First check the state
    final wrapperState = context.read<TimeLinesWrapperBloc>().state;
    if (wrapperState is! TimeLinesWrapperLoaded){
      return;
    }


    final earliest = wrapperState.earliest;
    if (earliest == null){
      return;
    }

    // Find the column the event belongs to by id 
    ScrollController? controller;
    for (final entry in wrapperState.timelines.entries) {
      if (entry.value.events.any((e) => e.id == event.id)) {
        controller = _timelineScrollControllers[entry.key];
        break;
      }
    }

    // If none is found return
    if (controller == null || !controller.hasClients){
      return;
    }

    final double eventTop = event.startDuration.difference(earliest).inMinutes * TimelineConstants.pixelsPerMinute;
    final ScrollController target = controller;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!target.hasClients){
        return;
      }

      final position = target.position;
      final double offset = (eventTop - position.viewportDimension * 0.25).clamp(0.0, position.maxScrollExtent);
      target.animateTo(
        offset,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  // Calculate the minheigt for the view so each column has the same height
  double _calculateMinHeight(List<MapEntry<int, Timeline>> activeTimelines, DateTime earliest) {
    double maxHeight = 0.0;

    for (final entry in activeTimelines) {
      final widget = entry.value.timelineWidget;
      if (widget is! TimelineContent){
         continue;
      }

      for (final event in widget.listOfEvents) {
        final height = event.endDuration.difference(earliest).inMinutes * TimelineConstants.pixelsPerMinute;
        if (height > maxHeight){
          maxHeight = height;
        } 
      }
    }

    return maxHeight;
  }
}
