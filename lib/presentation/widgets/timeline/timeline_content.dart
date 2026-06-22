import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:software_for_nature/core/constants/timeline_constants.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/logic/bloc/timeline/timeline_bloc.dart';
import 'package:software_for_nature/presentation/models/timeline_geometry.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_event_card.dart';

class TimelineContent extends StatefulWidget {

  final double minHeight;
  final List<EventPost> listOfEvents;
  final ScrollController? scrollController;
  final DateTime? earliest;
  final Color? groupColor;

  /// MOBILE: When false the column's own horizontal scroll is disabled this is for mobile the user has to click the column first
  final bool enableHorizontalScroll;

  const TimelineContent({
    super.key,
    required this.listOfEvents,
    this.earliest,
    this.scrollController,
    this.groupColor,
    this.minHeight = 0,
    this.enableHorizontalScroll = true,
  });

  @override
  State<TimelineContent> createState() => _TimelineContentState();
}

class _TimelineContentState extends State<TimelineContent> {
  Map<int, List<EventPost>> listOfRows = {};
  final ScrollController _horizontalScrollController = ScrollController();
  bool _hasExpandedCard = false;

  // The last focus request handled, so a marker hover scrolls this column
  // horizontally to the event only once per request.
  int _lastFocusRequestId = 0;

  @override
  void initState() {
    super.initState();
    calculateRows();
  }

  @override
  void didUpdateWidget(covariant TimelineContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldIds = oldWidget.listOfEvents.map((e) => e.id).join(',');
    final newIds = widget.listOfEvents.map((e) => e.id).join(',');

    if (oldIds != newIds) {
      listOfRows = {};
      calculateRows();
    }

    // MOBILE: Keep the scroll where the user left it when unfocusing a column on mobile
    if (oldWidget.enableHorizontalScroll != widget.enableHorizontalScroll && _horizontalScrollController.hasClients) {
      final double offset = _horizontalScrollController.offset;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_horizontalScrollController.hasClients){
          return;
        } 
        final double max = _horizontalScrollController.position.maxScrollExtent;
        _horizontalScrollController.jumpTo(offset.clamp(0.0, max));
      });
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.listOfEvents.isEmpty) {
      return Container(
        color: (widget.groupColor ?? Colors.blueGrey).withValues(alpha: 0.75),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: const Text(
          'No events found',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
        ),
      );
    }

    var timelineGeometry = TimelineGeometry.fromEvents(widget.listOfEvents, earliest: widget.earliest);

    final groupColor =
        widget.listOfEvents.first.group?.color ??
        widget.groupColor ??
        Colors.blue;


    return BlocListener<TimelineBloc, TimelineState>(
      listener: (context, state) {
        if (state is! TimelineInitial){
          return;
        }

        final selected = state.selectedPost;
        final inThisColumn = selected != null && widget.listOfEvents.any((e) => e.id == selected.id);
        _hasExpandedCard = inThisColumn;

        if (inThisColumn && state.focusRequestId != _lastFocusRequestId) {
          _lastFocusRequestId = state.focusRequestId;
          _scrollToEventHorizontally(selected);
        }
      },
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            final scrollHorizontally = HardwareKeyboard.instance.isControlPressed || _hasExpandedCard;
            if (scrollHorizontally) {
              final newOffset =(_horizontalScrollController.offset + event.scrollDelta.dy).clamp(0.0, _horizontalScrollController.position.maxScrollExtent,);
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
                  physics: widget.enableHorizontalScroll ? null : const NeverScrollableScrollPhysics(),
                  
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
                          final result = _buildCards(selectedId, timelineGeometry.earliest);

                          return SizedBox(
                            height: timelineGeometry.totalHeight + 16,
                            width: result.contentWidth,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: result.cards,
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
    );
  }

  /// Builds the positioned event cards for the stack and reports the total
  /// content width. The selected card (if any) is added last so it paints on
  /// top, with a dimming scrim behind it to make it stand out.
  ({List<Widget> cards, double contentWidth}) _buildCards(String? selectedId, DateTime earliest,) {
    final cards = <Widget>[];
    Widget? selectedCard;
    double contentWidth = TimelineConstants.cardWithIncMargins * listOfRows.length;

    // Build rows * columns
    for (var entry in listOfRows.entries) {
      for (final event in entry.value) {
        final card = Positioned(
          key: ValueKey(event.id),
          left: entry.key * TimelineConstants.cardWithIncMargins,
          top: event.startDuration.difference(earliest).inMinutes * TimelineConstants.pixelsPerMinute,
          child: TimelineEventCard(event: event),
        );

        if (event.id == selectedId) {
          selectedCard = card;
          final expandedRight = entry.key * TimelineConstants.cardWithIncMargins + TimelineConstants.expandedCardWidth;
          if (expandedRight > contentWidth) {
            contentWidth = expandedRight;
          }
        } else {
          cards.add(card);
        }
      }
    }

    if (selectedCard != null) {
      cards.add(selectedCard);
    }

    return (cards: cards, contentWidth: contentWidth);
  }

  void calculateRows() {

    // Sort by start time
    final sorted = [...widget.listOfEvents]..sort((a, b) => a.startDuration.compareTo(b.startDuration));

    for (EventPost event in sorted) {
      bool placed = false;
      for (int row = 0; row < listOfRows.length; row++) {
        bool overlaps = listOfRows[row]!.any(
          (existing) =>
              event.startDuration.isBefore(existing.endDuration) && 
              event.endDuration.isAfter(existing.startDuration) || event.startDuration == existing.startDuration,
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
    return minutes * TimelineConstants.pixelsPerMinute;
  }

  /// When requested scroll to the event horizontally
  void _scrollToEventHorizontally(EventPost event) {
    int? rowIndex;
    for (final entry in listOfRows.entries) {
      if (entry.value.any((e) => e.id == event.id)) {
        rowIndex = entry.key;
        break;
      }
    }
    if (rowIndex == null) return;

    final double targetLeft = rowIndex * TimelineConstants.cardWithIncMargins;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_horizontalScrollController.hasClients){
        return;
      }

      final position = _horizontalScrollController.position;
  
      // Add a little bit off offset
      final double offset = (targetLeft - position.viewportDimension * 0.25).clamp(0.0, position.maxScrollExtent);

      // Scroll to the position
      _horizontalScrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }
}
