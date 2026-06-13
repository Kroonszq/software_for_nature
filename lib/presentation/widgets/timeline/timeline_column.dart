import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/logic/bloc/timeline/timeline_bloc.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_event_card.dart';

class TimelineColumn extends StatefulWidget {
  static const double pixelsPerMinute = 2.0;

  /// Determines how much the card expands when hovered.
  static const double expandedCardWidth = 288.0;

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
  bool _hasExpandedCard = false;

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

    final localEarliest = widget.listOfEvents.map((e) => e.startDuration).reduce((a, b) => a.isBefore(b) ? a : b);
    final earliest = widget.earliest ?? localEarliest;

    final latest = widget.listOfEvents.map((e) => e.endDuration).reduce((a, b) => a.isAfter(b) ? a : b);

    final totalMinutes = latest.difference(earliest).inMinutes;
    final totalHeight = totalMinutes * TimelineColumn.pixelsPerMinute;
    final columnWidth = 108.0; // card width (100) + margins (4+4)

    final groupColor = widget.listOfEvents.first.group.color;

    return BlocProvider(
      create: (context) => TimelineBloc(),
      child: BlocListener<TimelineBloc, TimelineState>(
        listener: (context, state) {
          _hasExpandedCard = state is TimelineInitial && state.selectedPost != null;
        },
        child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            final scrollHorizontally = HardwareKeyboard.instance.isControlPressed || _hasExpandedCard;
            if (scrollHorizontally) {
              final newOffset = (_horizontalScrollController.offset + event.scrollDelta.dy).clamp(0.0, _horizontalScrollController.position.maxScrollExtent);
              _horizontalScrollController.jumpTo(newOffset);
            }
          }
        },
        child: Container(
          color: groupColor.withValues(alpha: 0.75),
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
                        child: BlocBuilder<TimelineBloc, TimelineState>(
                          builder: (context, state) {
                            final selectedId = state is TimelineInitial ? state.selectedPost?.id : null;
                            final cards = <Widget>[];
                            Widget? selectedCard;
                            double contentWidth = columnWidth * listOfRows.length;

                            // Build rows * columns
                            for (var entry in listOfRows.entries) {
                              for (final event in entry.value) {
                                final card = Positioned(
                                  key: ValueKey(event.id),
                                  left: entry.key * columnWidth, // X: which column (row index)
                                  top: event.startDuration.difference(earliest).inMinutes * TimelineColumn.pixelsPerMinute, // Y: time offset from earliest
                                  child: TimelineEventCard(event: event),
                                );
                                if (event.id == selectedId) {
                                  selectedCard = card;
                                  final expandedRight = entry.key * columnWidth + TimelineColumn.expandedCardWidth;
                                  if (expandedRight > contentWidth) {
                                    contentWidth = expandedRight;
                                  }
                                } else {
                                  cards.add(card);
                                }
                              }
                            }
                            if (selectedCard != null) cards.add(selectedCard);

                            return SizedBox(
                              height: totalHeight + 16,
                              width: contentWidth,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: cards,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }


  void calculateRows() {
    // Sort by start time
    final sorted = [...widget.listOfEvents]
      ..sort((a, b) => a.startDuration.compareTo(b.startDuration));

    for (EventPost event in sorted) {
      bool placed = false;
      for (int row = 0; row < listOfRows.length; row++) {
        bool overlaps = listOfRows[row]!.any(
          (existing) =>
            event.startDuration.isBefore(existing.endDuration) &&
            event.endDuration.isAfter(existing.startDuration) ||
            event.startDuration == existing.startDuration,
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