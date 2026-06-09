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
        final allEvents = state.allEvents;
        final earliest = state.earliest;
        final latest = state.latest;

        if (allEvents.isEmpty || earliest == null || latest == null) {
          return const Center(child: Text('No events'));
        }

        final double minHeight = _calculateMinHeight(activeTimelines, earliest);

        return Row(
          children: [
            // Minimized events stack
            const MinimizedEventsStack(),
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
                  
                  final columnWidth = activeCount > 0 
                      ? constraints.maxWidth / activeCount 
                      : constraints.maxWidth;

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
                          SizedBox(
                            key: ValueKey(state.timelineOrder[i]),
                            width: columnWidth, 
                            child: Column(
                              children: [
                                // Timeline header
                                TimelineHeader(
                                    title: 'Timeline ${state.timelineOrder[i]}',
                                    groupName: state.timelines[state.timelineOrder[i]]!.events.isNotEmpty
                                        ? state.timelines[state.timelineOrder[i]]!.events.first.group.title
                                        : 'Timeline ${state.timelineOrder[i]}',
                                    position: i,
                                    color: state.timelines[state.timelineOrder[i]]!.events.isNotEmpty
                                        ? state.timelines[state.timelineOrder[i]]!.events.first.group.color
                                        : Colors.blue,
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
                                          minHeight: minHeight,
                                        )
                                      : const SizedBox(),
                                ),
                              ],
                            ),
                          ),
                    ],
                  );
                },
              ),
            ),
            const VerticalDivider(width: 1),
            TimelineSideBar(),
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