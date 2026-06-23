import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/core/constants/timeline_constants.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/presentation/models/timeline.dart';
import 'package:software_for_nature/presentation/models/timeline_view_layout.dart';
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

  /// The shared vertical scroll offset of the timelines mirrored to the previews in the sidebar
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);

  // On mobile when an event is tapped it is focused
  int? _focusedTimelineKey;

  bool _overlaySidebarMinimized = false;

  void _initControllers(TimeLinesWrapperLoaded state) {
    // Dispose old controller so we dont have dupes
    for (final c in _timelineScrollControllers.values) {
      c.dispose();
    }

    // For each timeline create a controller with a listener so we can react and modify based upon event that are happening
    _timelineScrollControllers = {
      for (final entry in state.timelines.entries)
        entry.key: ScrollController()
          ..addListener(() {
            final controller = _timelineScrollControllers[entry.key]!;
            final offset = controller.offset;

            // Mirror to the preview rail
            _scrollOffset.value = offset;

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
    _scrollOffset.dispose();
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

          // No categories show to user
          if (state.timelines.isEmpty) {
            return const Center(child: Text('No timelines'));
          }

          return _buildLoaded(context, state);
        },
      ),
    );
  }

  /// Builds the loaded view with the layout, the main content row
  Widget _buildLoaded(BuildContext context, TimeLinesWrapperLoaded state) {
    final earliest = state.earliest ?? DateTime.now();
    final latest = state.latest ?? earliest;
    final minHeight = _calculateMinHeight(state.timelines.entries.toList(), earliest);
    final layout = TimelineViewLayout.resolve(context, overlayRequested: widget.overlaySidebar);

    final content = _buildContent(
      context,
      state,
      layout,
      earliest: earliest,
      latest: latest,
      minHeight: minHeight,
    );

    if (!layout.overlaySidebar) {
      return content;
    }

    return _buildSidebarOverlay(context, content, minHeight: minHeight, earliest: earliest);
  }

  /// The main horizontal layout with the minimized stack, time axis, timelines and previews
  Widget _buildContent(BuildContext context, TimeLinesWrapperLoaded state, TimelineViewLayout layout, { required DateTime earliest, required DateTime latest, required double minHeight }) {
    return Row(
      children: [
        // Minimized events stack
        if (!layout.isCompact) const MinimizedEventsStack(),
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
          child: _buildTimelinesList(
            context,
            state,
            layout,
            earliest: earliest,
            minHeight: minHeight,
          ),
        ),

        // Inline previews rail only when we have room for it
        if (layout.showSidebar && !layout.overlaySidebar) ...[
          const VerticalDivider(width: 1),
          TimelineSideBar(
            scrollOffset: _scrollOffset,
            contentHeight: minHeight,
            earliest: earliest,
          ),
        ],
      ],
    );
  }

  /// The horizontall list of timeline columns
  Widget _buildTimelinesList(BuildContext context, TimeLinesWrapperLoaded state, TimelineViewLayout layout, { required DateTime earliest, required double minHeight}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final List<int> activeOrderIndices = [
          for (int i = 0; i < state.timelineOrder.length; i++)
            if (state.timelines[state.timelineOrder[i]]?.active == true) i,
        ];
        final int activeCount = activeOrderIndices.length;

        // On mobile show 1 1/3 columns in the viewport
        final double columnWidth;
        if (layout.isCompact) {
          columnWidth = activeCount > 1
              ? constraints.maxWidth * 0.90
              : constraints.maxWidth;
        } else if (layout.overlaySidebar) {

          // On hybrid view keep 2 1/3 timelines visible in the viewport
          const double visibleColumns = 2 + 1 / 3;
          final double divisor = activeCount < visibleColumns ? activeCount.toDouble() : visibleColumns;
          
          columnWidth = activeCount > 0
              ? constraints.maxWidth / divisor
              : constraints.maxWidth;
        } else {

          // On the full timeline view keep 3 1/3 timelines visible in the
          // viewport; any beyond that scroll horizontally.
          const double visibleColumns = 3 + 1 / 3;
          final double divisor = activeCount < visibleColumns ? activeCount.toDouble() : visibleColumns;

          columnWidth = activeCount > 0
              ? constraints.maxWidth / divisor
              : constraints.maxWidth;
        }

        return ReorderableListView(
          scrollDirection: Axis.horizontal,
          buildDefaultDragHandles: false,
          onReorderItem: (oldIndex, newIndex) {
            // oldIndex/newIndex are positions within the active childre
            final int fullOld = activeOrderIndices[oldIndex];
            final int fullNew = newIndex < activeOrderIndices.length
                ? activeOrderIndices[newIndex]
                : activeOrderIndices.last + 1;
            context.read<TimeLinesWrapperBloc>().add(
              ReorderTimeline(fullOld, fullNew),
            );
          },
          children: [
            for (int pos = 0; pos < activeCount; pos++)
              Builder(
                  key: ValueKey(state.timelineOrder[activeOrderIndices[pos]]),
                  builder: (context) {
                    final int timelineKey = state.timelineOrder[activeOrderIndices[pos]];
                    final Timeline timeline = state.timelines[timelineKey]!;
                    final bool isFocused = layout.isCompact && _focusedTimelineKey == timelineKey;

                    return TimelineColumn(
                      timeline: timeline,
                      timelineKey: timelineKey,
                      position: pos,
                      width: timeline.fullscreen ? constraints.maxWidth : columnWidth,
                      isFocused: isFocused,
                      enableHorizontalScroll: !layout.isCompact || isFocused,
                      earliest: earliest,
                      minHeight: minHeight,
                      scrollController: _timelineScrollControllers[timelineKey],
                      onTap: layout.isCompact
                          ? () => setState(() {
                              _focusedTimelineKey = isFocused
                                  ? null
                                  : timelineKey;
                            })
                          : null,
                      onMinimize: () => context
                          .read<TimeLinesWrapperBloc>()
                          .add(SetTimelineInActive(timelineKey)),
                      onFullScreen: () => context
                          .read<TimeLinesWrapperBloc>()
                          .add(SetTimelineFullscreen(timelineKey)),
                    );
                  },
                ),
          ],
        );
      },
    );
  }

  /// Floats the previews rail on top of [content] on the right side this only gets used when we dont have a lot of space
  Widget _buildSidebarOverlay(BuildContext context, Widget content, {required double minHeight, required DateTime earliest}) {
    const double sidebarOverlayWidth = 220;
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
                  scrollOffset: _scrollOffset,
                  contentHeight: minHeight,
                  earliest: earliest,
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
