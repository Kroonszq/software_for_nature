import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/logic/bloc/timeline/timeline_bloc.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_event_card.dart';

class TimelineColumn extends StatefulWidget {
  static const double pixelsPerMinute = 2.0;
  final double minHeight;
  final List<EventPost> listOfEvents;
  final ScrollController? scrollController;
  final DateTime? earliest;

  const TimelineColumn({
    super.key,
    required this.listOfEvents,
    this.earliest,
    this.scrollController,
    this.minHeight = 0,
  });

  @override
  State<TimelineColumn> createState() => _TimelineColumnState();
}

class _TimelineColumnState extends State<TimelineColumn> {
  Map<int, List<EventPost>> listOfRows = {};
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    calculateRows();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.listOfEvents.isEmpty) return const SizedBox();

    final earliest = widget.listOfEvents
        .map((e) => e.startDuration)
        .reduce((a, b) => a.isBefore(b) ? a : b);

    final latest = widget.listOfEvents
        .map((e) => e.endDuration)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    final totalMinutes = latest.difference(earliest).inMinutes;
    final totalHeight = totalMinutes * TimelineColumn.pixelsPerMinute;
    final columnWidth = 108.0; // card width (100) + margins (4+4)

    return BlocProvider(
      create: (context) => TimelineBloc(),
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            final isCtrlHeld = HardwareKeyboard.instance.isControlPressed;
            if (isCtrlHeld) {
              final newOffset = (_horizontalScrollController.offset +
                      event.scrollDelta.dy)
                  .clamp(
                0.0,
                _horizontalScrollController.position.maxScrollExtent,
              );
              _horizontalScrollController.jumpTo(newOffset);
            }
          }
        },
        child: Scrollbar(
          controller: _horizontalScrollController,
          thumbVisibility: true,
          trackVisibility: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  controller: widget.scrollController,
                  scrollDirection: Axis.vertical,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: widget.minHeight,
                      minWidth: constraints.maxWidth,
                    ),
                    child: SizedBox(
                      height: totalHeight + 16,
                      width: columnWidth * listOfRows.length,
                      child: Stack(
                        children: [
                          for (var entry in listOfRows.entries)
                            for (final event in entry.value)
                              Positioned(
                                // X: which column (row index)
                                left: entry.key * columnWidth,
                                // Y: time offset from earliest
                                top: event.startDuration
                                        .difference(earliest)
                                        .inMinutes *
                                    TimelineColumn.pixelsPerMinute,
                                width: columnWidth,
                                child: TimelineEventCard(event: event),
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }


  void calculateRows() {
    // Sort by start time first
    final sorted = [...widget.listOfEvents]
      ..sort((a, b) => a.startDuration.compareTo(b.startDuration));

    for (EventPost event in sorted) {
      bool placed = false;
      for (int row = 0; row < listOfRows.length; row++) {
        bool overlaps = listOfRows[row]!.any(
          (existing) =>
            event.startDuration.isBefore(existing.endDuration) &&
            event.endDuration.isAfter(existing.startDuration) ||
            event.startDuration == existing.startDuration, // <-- same start = overlap
        );
        if (!overlaps) {
          listOfRows[row]!.add(event);
          placed = true;
          break;
        }
      }
      if (!placed) {
        listOfRows[listOfRows.length] = [event];
      }
    }
  }

  double getHeight(EventPost event) {
    final minutes = event.endDuration.difference(event.startDuration).inMinutes;
    return minutes * TimelineColumn.pixelsPerMinute;
  }
}