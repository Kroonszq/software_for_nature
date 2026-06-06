import 'dart:io';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/logic/bloc/timeline/timeline_bloc.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_event_card.dart';

class TimelineColumn extends StatefulWidget {
  static const double pixelsPerMinute = 2.0;
  final double minHeight;
  final List<EventPost> listOfEvents;
  final ScrollController? scrollController;

  const TimelineColumn({
    super.key,
    required this.listOfEvents,
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
        child: SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            controller: widget.scrollController,
            scrollDirection: Axis.vertical,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: widget.minHeight,
                minWidth: 400,
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var entry in listOfRows.entries)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final event in entry.value)
                            TimelineEventCard(event: event),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
  void calculateRows() {
    for (EventPost event in widget.listOfEvents) {
      bool placed = false;
      for (int row = 0; row < listOfRows.length; row++) {
        bool overlaps = listOfRows[row]!.any(
          (existing) =>
              event.startDuration.isBefore(existing.endDuration) &&
              event.endDuration.isAfter(existing.startDuration),
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