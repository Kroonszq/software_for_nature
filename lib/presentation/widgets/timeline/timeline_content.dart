import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:software_for_nature/core/constants/timeline_constants.dart';
import 'package:software_for_nature/data/models/event_attachment.dart';
import 'package:software_for_nature/data/models/event_chart.dart';
import 'package:software_for_nature/data/models/event_post.dart';
import 'package:software_for_nature/logic/bloc/timeline/timeline_bloc.dart';
import 'package:software_for_nature/presentation/models/timeline_geometry.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_event_card.dart';
import 'package:software_for_nature/presentation/widgets/timeline/timeline_offscreen_event_indicator.dart';

class TimelineContent extends StatefulWidget {
  final double minHeight;
  final List<EventPost> listOfEvents;
  final ScrollController? scrollController;
  final DateTime? earliest;
  final Color? groupColor;

  /// MOBILE: When false the column's own horizontal scroll is disabled this is for mobile the user has to click the column first
  final bool enableHorizontalScroll;

  /// Whether to overlay the floating "N events above/below" counter disabled  for the small sidebar previews, which should stay uncluttered.
  final bool showOffscreenIndicators;

  const TimelineContent({
    super.key,
    required this.listOfEvents,
    this.earliest,
    this.scrollController,
    this.groupColor,
    this.minHeight = 0,
    this.enableHorizontalScroll = true,
    this.showOffscreenIndicators = true,
  });

  @override
  State<TimelineContent> createState() => _TimelineContentState();
}

class _TimelineContentState extends State<TimelineContent> {
  Map<int, List<EventPost>> listOfRows = {};
  final ScrollController _horizontalScrollController = ScrollController();
  bool _hasExpandedCard = false;
  final ValueNotifier<ScrollMetrics?> _verticalMetrics = ValueNotifier<ScrollMetrics?>(null);
  ScrollPosition? _verticalPosition;

  /// Records the latest vertical metrics (for the counters) and resolves the
  /// active scroll position (for tap-to-scroll) from the notification context.
  void _captureVertical(ScrollMetrics metrics,BuildContext? notificationContext) {
    if (metrics.axis != Axis.vertical){
      return;
    } 

    _verticalMetrics.value = metrics;
    if (notificationContext != null) {
      _verticalPosition = Scrollable.maybeOf(notificationContext)?.position;
    }
  }

  int _lastFocusRequestId = 0;

  @override
  void initState() {
    super.initState();
    calculateRows();
  }

  @override
  void didUpdateWidget(covariant TimelineContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    // recalculate the row layout when the events change
    final oldSignature = _eventsSignature(oldWidget.listOfEvents);
    final newSignature = _eventsSignature(widget.listOfEvents);

    if (oldSignature != newSignature) {
      listOfRows = {};
      calculateRows();
    }

    // MOBILE: Keep the scroll where the user left it when unfocusing a column on mobile
    if (oldWidget.enableHorizontalScroll != widget.enableHorizontalScroll &&
        _horizontalScrollController.hasClients) {
      final double offset = _horizontalScrollController.offset;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_horizontalScrollController.hasClients) {
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
    _verticalMetrics.dispose();
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

    var timelineGeometry = TimelineGeometry.fromEvents(
      widget.listOfEvents,
      earliest: widget.earliest,
    );

    final groupColor =
        widget.listOfEvents.first.category?.color ??
        widget.groupColor ??
        Colors.blue;

    return BlocListener<TimelineBloc, TimelineState>(
      listener: (context, state) {
        if (state is! TimelineInitial) {
          return;
        }

        final selected = state.selectedPost;
        final inThisColumn =
            selected != null &&
            widget.listOfEvents.any((e) => e.id == selected.id);
        _hasExpandedCard = inThisColumn;

        if (inThisColumn && state.focusRequestId != _lastFocusRequestId) {
          _lastFocusRequestId = state.focusRequestId;
          _scrollToEventHorizontally(selected);
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // capture vertical scroll metrics for the off screen counters
          NotificationListener<ScrollMetricsNotification>(
            onNotification: (n) {
              _captureVertical(n.metrics, n.context);
              return false;
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                _captureVertical(n.metrics, n.context);
                return false;
              },
              child: Listener(
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent) {
                    final scrollHorizontally = HardwareKeyboard.instance.isControlPressed || _hasExpandedCard;
                    if (scrollHorizontally) {
                      final newOffset = (_horizontalScrollController.offset + event.scrollDelta.dy)
                              .clamp(0.0,_horizontalScrollController.position.maxScrollExtent,
                              );
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
                          physics: widget.enableHorizontalScroll
                              ? null
                              : const NeverScrollableScrollPhysics(),

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
                                  final selectedId = state is TimelineInitial
                                      ? state.selectedPost?.id
                                      : null;
                                  final result = _buildCards(
                                    selectedId,
                                    timelineGeometry.earliest,
                                  );

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
            ),
          ),
          // floating counters showing how many events sit above/below the current vertical viewport
          if (widget.showOffscreenIndicators)
            Positioned.fill(
              child: OffscreenEventIndicators(
                metrics: _verticalMetrics,
                resolvePosition: () => _verticalPosition,
                events: widget.listOfEvents,
                earliest: timelineGeometry.earliest,
              ),
            ),
        ],
      ),
    );
  }

  /// builds the positioned event cards for the stack and reports the total content width 
  ({List<Widget> cards, double contentWidth}) _buildCards(String? selectedId, DateTime earliest) {
    final cards = <Widget>[];
    Widget? selectedCard;
    double contentWidth =
        TimelineConstants.cardWithIncMargins * listOfRows.length;

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
          final expandedRight =
              entry.key * TimelineConstants.cardWithIncMargins +
              TimelineConstants.expandedCardWidth;
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

  /// A fingerprint of the events that changes whenever any field affecting the
  /// layout or card content changes, so edits are caught
  /// nighmare ass hell
  String _eventsSignature(List<EventPost> events) {
    return events
        .map(
          (e) =>
              '${e.id}:${e.startDuration.millisecondsSinceEpoch}:${e.endDuration.millisecondsSinceEpoch}:${e.timestamp?.millisecondsSinceEpoch ?? ''}:${e.title}:${e.description}:${e.categoryId}:${_chartsSignature(e.charts)}:${_attachmentsSignature(e.attachments)}',
        )
        .join('|');
  }
  String _chartsSignature(List<EventChart> charts) => charts.map((c) => '${c.fileName}#${c.points.length}').join(',');
  String _attachmentsSignature(List<EventAttachment> attachments) => attachments.map((a) => a.name).join(',');

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
      if (!_horizontalScrollController.hasClients) {
        return;
      }

      final position = _horizontalScrollController.position;

      // Add a little bit off offset
      final double offset = (targetLeft - position.viewportDimension * 0.25)
          .clamp(0.0, position.maxScrollExtent);

      // Scroll to the position
      _horizontalScrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }
}

